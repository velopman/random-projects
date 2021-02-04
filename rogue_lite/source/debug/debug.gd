extends Node2D


export(int) var max_trees = 0
export(float) var min_distance = 500.0
export(float) var max_distance = 3000.0
#export(float) var min_distance = 250.0
#export(float) var max_distance = 500.0

onready var enemy_scene = load( "res://source/debug/enemy.tscn" )
onready var tree_scene = load( "res://source/debug/tree.tscn" )

var grid_size = 70
var cell_size = 64
var offset = 10

onready var main_node = self.get_node("/root/main")

func _ready() -> void:
	var offset = grid_size * cell_size / 2.0

	var squares = []

	for i in range( self.grid_size * 4 ):
		squares.append( {
			"x": randi() % (self.grid_size - 2 * self.offset) + self.offset,
			"y": randi() % (self.grid_size - 2 * self.offset) + self.offset,
			"size": randi() % 5,
		})

	squares.append( {
		"x": self.grid_size / 2 - self.offset / 2,
		"y": self.grid_size / 2 - self.offset / 2,
		"size": self.offset,
	} )

	for x in range( self.grid_size ):
		for y in range( self.grid_size ):
			var position = Vector2(
				cell_size * x - offset,
				cell_size * y - offset
			)

			var in_squares = false

			for square in squares:
				if self.in_square(x, y,
					square[ "x" ], square[ "y" ], square[ "size" ] ):
					in_squares = true
					break

			if !self.in_square( x, y, self.offset, self.offset, self.grid_size - self.offset * 2 ) || !in_squares:

				self.spawn_instance( self.tree_scene, position )

				continue

			var player_position = GlobalReferences.player_instance.position
			var player_distance = (player_position - position).length()

			if randi() % 10 == 0 && player_distance > 10 * self.cell_size:
				self.spawn_instance( self.enemy_scene, position)


func spawn_instance( scene: Resource, position: Vector2 ) -> void:
	var instance = scene.instance()

	instance.position = position

	self.main_node.call_deferred( "add_child", instance )


func in_square( pos_x: int, pos_y: int, x: int, y: int, size: int ) -> bool:
	return x <= pos_x && pos_x <= x + size && y <= pos_y && pos_y <= y + size
