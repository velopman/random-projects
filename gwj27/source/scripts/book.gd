extends Area2D
class_name book


var target = null

var is_thrown = false
var __throw_direction = null
var __throw_force = null

var __bounce_location = null

var __owner = null
var __owned_position = null

var color = Color.white

onready var __screen_rect = self.get_viewport_rect()

var __time_remaining = 0.0

func _ready():
	$sprite.material = $sprite.material.duplicate()
	$sprite.material.set_shader_param("replacement_color", self.color)
	
	self.add_to_group("book")


func _process(delta):
	self.__handle_throwing(delta)
	self.__handle_bouncing(delta)
	self.__handle_owned(delta)


func _on_body_entered(body):
	var ability_orbit = body.get_node("ability_orbit")
	if ability_orbit:
		if body is dweller && self.is_thrown:
			ability_orbit.stun(5.0)
			self.is_thrown = false
		
		if ability_orbit.has_max_books() || ability_orbit.is_stunned():
			if self.__throw_direction:
				self.collision_mask = 0
				self.__bounce_location = body.position + self.__throw_direction * -50.0
			return
		
		if self.target && self.target.get_parent().get_class() != body.get_class():
			return
		
		if self.target:
			self.target.remove_book_from_orbit(self)
			var target_parent = self.target.get_parent()
			if target_parent is dweller:
				target_parent.decrease_happiness(5)
			
		ability_orbit.add_book_to_orbit(self)
		self.target = ability_orbit
		self.__owner = null
	
	# set transfer timer
	if body is dweller:
		self.collision_mask = 1
		body.increase_happiness(2)
	
	if body is player:
		self.collision_mask = 4


func throw(throw_direction, throw_force):
	self.__throw_direction = throw_direction.normalized()
	self.__throw_force = throw_force
	self.is_thrown = true
	
	self.target = null


func set_color(new_color):
	self.color = new_color


func set_owner(area):
	self.__owner = area
	self.target = null
	
	if self.__owner.color == self.color:
		self.collision_mask = 4
		self.__time_remaining = 5.0
	else:
		self.collision_mask = 1
	
	var offset_position = Vector2(randf() * 10.0, 0.0).rotated(randf() * PI * 2)
	self.__owned_position = area.position + offset_position


func set_target(new_target):
	if self.target:
		self.target.remove_book_from_orbit(self)
	
	self.target = new_target
	self.target.add_book_to_orbit(self)

func __handle_throwing(delta):
	if !self.is_thrown:
		return 
	
	if self.__is_moving_off_screen():
		var wall_normal = Vector2(-self.__throw_direction.x, 0.0)
		if abs(self.__throw_direction.y) > abs(self.__throw_direction.x):
			wall_normal = Vector2(0.0, -self.__throw_direction.y)
		
		var angle = wall_normal.dot(-self.__throw_direction)
		
		self.__bounce_location = self.position + -wall_normal.rotated(angle) * -30.0
		self.is_thrown = false
	
	self.position += self.__throw_direction * self.__throw_force * delta


func __handle_bouncing(delta):
	if !self.__bounce_location:
		return
	
	self.position = self.position.move_toward(self.__bounce_location, 300.0 * delta)
	
	if self.position == self.__bounce_location:
		self.__bounce_location = null
		self.collision_mask = 5


func __handle_owned(delta):
	if !self.__owner:
		return
	
	if self.__owner.color == self.color:
		self.__time_remaining = max(0.0, self.__time_remaining - delta)
		
		if self.__time_remaining == 0.0:
			self.queue_free()
	
	if self.position != self.__owned_position:
		self.position = self.position.move_toward(self.__owned_position, 300.0 * delta)

func __is_moving_off_screen():
	var probe = self.__throw_direction * 10.0 + self.position
	return !self.__screen_rect.has_point(probe)

func has_owner():
	return self.__owner != null

func is_owner_color():
	return self.__owner && self.__owner.color == self.color
