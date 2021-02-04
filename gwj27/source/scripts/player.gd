extends KinematicBody2D
class_name player

export var speed = 100.0

onready var __orbit_instance = self.get_node("ability_orbit")


func _ready():
	globals.player_instance = self

func _process(delta: float) -> void:
	self.__handle_input(delta)


func __handle_input(delta):
	if __orbit_instance.is_stunned():
		return
	
	var direction: Vector2 = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if Input.is_action_pressed("debug"):
		delta *= 2.0
	
	self.position += speed * delta * direction.normalized()
