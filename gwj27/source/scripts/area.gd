extends Area2D

export(Color) var color
onready var book_type = load("res://source/scenes/book.tscn")

func _ready():
	$sprite.material = $sprite.material.duplicate()
	$sprite.material.set_shader_param("replacement_color", color)
	$sprite.modulate = color
	
	self.add_to_group("area")


func _on_body_entered(body):
	var ability_orbit = body.get_node("ability_orbit")
	
	var books = []
	if body is dweller:
		books = ability_orbit.remove_books_for_color(self.color, false)
	
	if body is player:
		books = ability_orbit.remove_books_for_color(self.color, true)
	
	if !books:
		return
	
	for book in books:
		book.set_owner(self)

