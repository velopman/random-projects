extends Area2D
class_name Bullet

var setable_properties = [
	"arc_chance",
	"arc_drop_off",
	"direction",
	"life_remaining",
	"pierce_remaining",
	"speed",
]


var speed: float = 1000.0

var direction: Vector2 = Vector2.ZERO

var off_screen_elapsed: float = 0.0

var life_remaining: float = 5.0
var pierce_remaining: int = 1

var arc_chance: float  = 0.0
var arc_drop_off: float = 1.0

var seen_targets: Array = []


func _process( delta: float ) -> void:
	self.position += self.direction * self.speed * delta

	if !$visibility_notifier.is_on_screen():
		self.call_deferred( "queue_free" )

	self.life_remaining = max( 0.0, self.life_remaining - delta )
	if self.life_remaining == 0.0:
		self.call_deferred( "queue_free" )


func _on_body_entered( body ) -> void:
	if body in self.seen_targets:
		return

	self.seen_targets.append( body )

	if body is Player:
		self.player_collision_handler( body )

	if body is Enemy:
		self.enemy_collision_handler( body )

	if body is StaticBody2D:
		self.call_deferred( "queue_free" )


func player_collision_handler( player: Player ) -> void:
	player.damage( 1 )
	self.call_deferred( "queue_free" )


func enemy_collision_handler( enemy: Enemy ) -> void:
	enemy.call_deferred( "queue_free" )
	enemy.bullet_ring( 0.0 )

	self.pierce_remaining -= 1
	if self.pierce_remaining == 0:
		self.call_deferred( "queue_free" )

	if self.arc_chance > 0.0:
		if randf() > self.arc_chance:
			self.call_deferred( "queue_free" )
		else:
			self.arc_chance *= self.arc_drop_off

			var nearest_enemy = null
			var nearest_distance = 250.0

			for other in self.get_tree().get_nodes_in_group( "enemy" ):
				if enemy == other:
					continue

				var distance = ( enemy.position - other.position ).length()
				if distance < nearest_distance:
					nearest_enemy = other
					nearest_distance = distance

			if nearest_enemy != null:
				self.direction = ( nearest_enemy.position - enemy.position ).normalized()

	GlobalReferences.player_instance.call_deferred( "heal", 2 )
