extends KinematicBody2D
class_name dweller

enum dweller_state { patrolling = 0, chasing, placing, bored }

export var speed = 50.0
export var chasing_modifier = 2.0

onready var __screen_rect = self.get_viewport_rect()

var __state = dweller_state.patrolling
onready var __state_handlers = {
	dweller_state.patrolling: funcref(self, "__handle_patrolling"),
	dweller_state.chasing: funcref(self, "__handle_chasing"),
	dweller_state.placing: funcref(self, "__handle_chasing"),
	dweller_state.bored: funcref(self, "__handle_chasing"),
}

var __directions = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT,
]
onready var __current_direction = Vector2.DOWN

var __sight_distance = 100.0
var __sight_angle = PI * 0.5
var __target_location = null
var __arrived_distance = 5.0

onready var __orbit_instance = self.get_node("ability_orbit")

onready var __scene_tree = self.get_tree()

var __happiness = 100
onready var __exit_location = self.position


func _process(delta):
	if __orbit_instance.is_stunned():
		return
	
	if randi() % 100 == 0:
		self.decrease_happiness(1)
	
	self.__handle_state_transition()
	self.__state_handlers[self.__state].call_func(delta)


func __handle_state_transition():
	if self.__happiness == 0.0 && !self.__orbit_instance.has_orbiting():
		self.__state = dweller_state.bored
		self.__target_location = self.__exit_location
		
		if self.__arrived_at_target():
			self.get_parent().dweller_left()
			self.queue_free()
		return
	
	var target_book = self.__find_closest_book()
	if target_book:
		self.__target_location = target_book.position
		self.__state = dweller_state.chasing
		return
	
	if self.__state == dweller_state.placing:
		if self.__arrived_at_target():
			self.__happiness += 5
		else:
			return
	
	var target_area = self.__find_placement_area()
	if target_area:
		self.__target_location = target_area.position
		self.__state = dweller_state.placing
		return
	
	self.__state = dweller_state.patrolling

# patrolling 
#	walk in a direction
#	sometimes change directions (90 degree turns)
#	stay in bounds 
func __handle_patrolling(delta):
	if !self.__current_direction || self.__is_moving_off_screen() || randi() % 100 == 0 :
		var direction_index = randi() % 4
		self.__current_direction = self.__directions[direction_index]
		
		while self.__is_moving_off_screen():
			direction_index = (direction_index + 1) % 4
			self.__current_direction = self.__directions[direction_index]
	
	self.position += self.__current_direction * self.speed * delta


# chasing
#	entered by seeing the player in its field of view (angle + distance)
#	will chase player until it loses sight
func __handle_chasing(delta):
	var direction_delta = self.__target_location - self.position
	
	self.__current_direction = direction_delta.normalized()
	self.position += self.__current_direction * self.speed * self.chasing_modifier * delta


func __arrived_at_target():
	var position_delta = self.__target_location - self.position
	return self.__target_location && position_delta.length() < self.__arrived_distance


func __find_closest_book():
	if self.__orbit_instance.has_max_books():
		return
	
	var closest_book = null
	var closest_distance = self.__sight_distance
	
	for book in self.__scene_tree.get_nodes_in_group("book"):
		if book.target == $ability_orbit:
			continue
		
		if book.target && book.target.get_parent().get_class() != self.get_class():
			continue
		
		if book.has_owner() && !book.is_owner_color():
			continue
		
		var delta = book.position - self.position 
		
		if abs(delta.length()) > closest_distance:
			continue
		
		if delta.dot(self.__current_direction) <= 0:
			continue
		
		closest_book = book
		closest_distance = delta.length()
		
	return closest_book


func __find_placement_area():
	if !self.__orbit_instance.has_orbiting():
		return
	
	var book_colors = self.__orbit_instance.get_book_colors()
	var potential_areas = []
	
	for area in self.__scene_tree.get_nodes_in_group("area"):
		if book_colors.find(area.color) == -1:
			potential_areas.append(area)
	
	if !potential_areas:
		return null
	
	return potential_areas[randi() % potential_areas.size()]


func __is_moving_off_screen():
	var probe = self.__current_direction * 50.0 + self.position
	return !self.__screen_rect.has_point(probe)

func increase_happiness(amount):
	self.__happiness += amount

func decrease_happiness(amount):
	self.__happiness = max(0.0, self.__happiness - amount)
