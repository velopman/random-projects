extends KinematicBody2D
class_name Enemy

var bullet_cooldown: float = 0.5
var bullet_patterns = [
	funcref( self, "bullet_ring" ),
	funcref( self, "bullet_gattling" ),
]
onready var bullet_pattern = randi() % self.bullet_patterns.size()

onready var bullet_scene = load( "res://source/debug/bullet.tscn" )

var aim_direction = Vector2.ZERO

onready var player_instance = self.get_node( "/root/main/player" )

var speed = 100.0

func _ready() -> void:
	self.add_to_group( "enemy" )


func _process( delta: float ) -> void:
	if $visibility_notifier.is_on_screen():
		self.bullet_cooldown = max( 0.0, self.bullet_cooldown - delta )

		if self.bullet_cooldown == 0.0:
			self.bullet_patterns[ self.bullet_pattern ].call_func( delta )

		if self.aim_direction == Vector2.ZERO:
			self.aim_direction = ( self.player_instance.position - self.position ).normalized()

		var movement = self.player_direction() * self.speed * delta
		self.move_and_collide( movement )


func bullet_ring( delta: float ) -> void:
	var max_bullets = 32.0

	for i in range( max_bullets ):
		var direction = Vector2.UP.rotated( ( PI * 2.0 ) * ( i / max_bullets ) )

		self.spawn_bullet(
			direction,
			{
				"speed": 250.0,
			}
		)

	self.bullet_cooldown = 2.5


func bullet_gattling( delta: float ) -> void:
	self.aim_direction = self.aim_direction.move_toward(
		self.player_direction(), 10.0 * delta
	).normalized()


	self.spawn_bullet(
		self.aim_direction,
		{
			"speed": 500.0,
		}
	)

	self.bullet_cooldown = 0.05


func spawn_bullet( direction: Vector2, options: Dictionary = {} ):
	var instance = self.bullet_scene.instance()

	instance.position = self.position + direction * 20.0
	instance.direction = direction

	for property in instance.setable_properties:
		if property in options:
			instance.set( property, options[ property] )

	instance.collision_layer = 32
	instance.collision_mask = 4

	self.get_parent().call_deferred( "add_child", instance )


func player_direction() -> Vector2:
	return ( self.player_instance.position - self.position ).normalized()
