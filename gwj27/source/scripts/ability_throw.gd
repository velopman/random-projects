extends Node

onready var __orbit_instance = self.get_parent().find_node("ability_orbit")
onready var __viewport_instance = self.get_viewport()

export var throw_force = 400.0

func _process(delta):
	if Input.is_action_just_pressed("left_click") && self.__orbit_instance.has_orbiting():
		self.__handle_throw_book()

func __handle_throw_book():
	var mouse_position = self.__viewport_instance.get_mouse_position()
	var book_instance = self.__orbit_instance.pop_book()
	var throw_direction = mouse_position - book_instance.position
	
	book_instance.throw(throw_direction.normalized(), self.throw_force)
