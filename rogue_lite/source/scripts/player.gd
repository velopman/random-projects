extends KinematicBody2D
class_name Player

export( float ) var speed = 100.0
export( int ) var max_health = 16
onready var health = self.max_health

onready var bullet_scene = load( "res://source/debug/bullet.tscn" )

onready var viewport = self.get_viewport()

var attacks = {
	"default": funcref( self, "attack_default" ),
	"spread": funcref( self, "attack_spread" ),
	"pierce": funcref( self, "attack_pierce" ),
	"arc": funcref( self, "attack_arc" ),
}
var attack = "default"
var attack_cooldown = 0.0

var invincibility_remaining = 0.0
const invincibility_max = 0.2

func _ready() -> void:
	GlobalReferences.player_instance = self


func _process( delta: float ) -> void:
	self.update_remaining()

	if self.invincibility_remaining > 0.0:
		self.invincibility_remaining = max( 0.0, self.invincibility_remaining - delta )

	var movement_direction = Vector2(
		Input.get_action_strength( "right" ) -
		Input.get_action_strength( "left" ),
		Input.get_action_strength( "down" ) -
		Input.get_action_strength( "up" )
	).normalized()

#	self.position += movement_direction * self.speed * delta
	self.move_and_collide( movement_direction * self.speed * delta )

	if attack_cooldown == 0.0 && Input.is_action_pressed( "fire" ):
		self.attacks[ attack ].call_func()

	if self.attack_cooldown > 0.0:
		self.attack_cooldown = max( 0.0, self.attack_cooldown - delta )


	var nearest_enemy = null
	var nearest_distance = 10000.0

	for enemy in self.get_tree().get_nodes_in_group( "enemy" ):
		if enemy == self:
			continue

		var distance = ( self.position - enemy.position ).length()
		if distance < nearest_distance:
			nearest_enemy = enemy
			nearest_distance = distance

	if nearest_enemy != null:
		var direction = ( nearest_enemy.position - self.position ).normalized()
		$arrow.position = direction * 100.0

		var angle = Vector2.UP.angle_to(direction)
		$arrow.rotation = angle



func update_sprite( name: String ) -> void:
	$sprite.play( name )


func heal( amount: int ) -> void:
	self.health = min( self.health + amount, self.max_health )
	$health.value = self.health / self.max_health


func damage( amount: int ) -> void:
	if self.invincibility_remaining > 0.0:
		return

	self.invincibility_remaining = self.invincibility_max

	self.health = max( 0.0, self.health - amount)
	$health.value = self.health / self.max_health

	if health == 0:
		self.get_tree().reload_current_scene()


func update_remaining():
	var remaining = self.get_tree().get_nodes_in_group( "enemy" ).size()
	$remaining.text = "%d enemies remaining" % [ remaining ]


func attack_default() -> void:
	self.spawn_bullet( self.mouse_direction() )

	self.attack_cooldown = 0.2


func attack_spread() -> void:
	var initial_direction = self.mouse_direction().rotated( -0.05 * PI )

	for i in range( 3 ):
		var instance = self.bullet_scene.instance()

		var direction = initial_direction.rotated( 0.05 * PI * i )

		self.spawn_bullet(
			direction,
			{
				"life_remaining": 0.2,
				"speed": 1500.0,
			}
		)

		self.attack_cooldown = 0.5


func attack_pierce() -> void:
	self.spawn_bullet(
		self.mouse_direction(),
		{
			"pierce_remaining": 3,
		}
	)

	self.attack_cooldown = 0.5


func attack_arc() -> void:
	self.spawn_bullet(
		self.mouse_direction(),
		{
			"arc_chance": 1.0,
			"arc_drop_off": 0.3,
			"pierce_remaining": 3,
			"speed": 750.0,
		}
	)

	self.attack_cooldown = 0.75

func spawn_bullet( direction: Vector2, options: Dictionary = {} ):
	var instance = self.bullet_scene.instance()

	instance.position = self.position + direction * 20.0
	instance.direction = direction

	for property in instance.setable_properties:
		if property in options:
			instance.set( property, options[ property] )


	instance.collision_layer = 8
	instance.collision_mask = 16

	self.get_parent().call_deferred( "add_child", instance )


func mouse_direction() -> Vector2:
	return (self.get_global_mouse_position() - self.position).normalized()
