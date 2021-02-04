extends Node2D

onready var dweller_type = load("res://source/scenes/dweller.tscn")
var __dweller_spawn_location = Vector2(512.0, -40.0)
var __dweller_count = 0
var __dweller_count_max = 10
var __dweller_cooldown = 0.0

onready var book_type = load("res://source/scenes/book.tscn")

onready var __scene_tree = self.get_tree()

func _ready():
	randomize()


func _process(delta):
	self.__dweller_cooldown = max(0.0, self.__dweller_cooldown - delta)
	
	if self.__dweller_cooldown == 0.0 && randi() % 100 == 0:
		spawn_dweller()


func spawn_dweller():
	if self.__dweller_count >= self.__dweller_count_max:
		return
	
	var dweller_instance = self.dweller_type.instance()
	
	var offset = Vector2(randf() * 50.0 - 25.0, 0.0)
	dweller_instance.set_position(self.__dweller_spawn_location + offset)
	
	self.add_child(dweller_instance)
	
	var ability_orbit = dweller_instance.get_node("ability_orbit")
	var possible_colors = []
	for area in self.__scene_tree.get_nodes_in_group("area"):
		possible_colors.append(area.color)
	
	for i in range(1 + randi() % 1):
		var book_instance = self.book_type.instance()
		
		book_instance.set_color(possible_colors[randi() % possible_colors.size()])
		book_instance.set_position(dweller_instance.position)
		book_instance.set_target(ability_orbit)
		
		self.add_child(book_instance)
		
	
	self.__dweller_count += 1
	self.__dweller_cooldown = 5.0

func dweller_left():
	self.__dweller_count -= 1
