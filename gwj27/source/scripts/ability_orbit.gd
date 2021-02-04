extends Node2D
class_name ability_orbit

export var max_books = 1

var __time_elapsed: float = 0.0
var __orbiting_books: Array = []
var __orbiting_book_colors: Array = []

var __stunned_time_remaining = 0.0


func _process(delta):
	self.__handle_orbiting_books(delta)
	self.__handle_stunned(delta)


func __handle_orbiting_books(delta):
	if self.__orbiting_books.size() == 0:
		return
	
	self.__time_elapsed += delta
	
	var angle = (2 * PI) / self.__orbiting_books.size()
	var offset = Vector2(0.0, 50.0)
	
	for i in range(self.__orbiting_books.size()):
		var book_offset = offset.rotated(self.__time_elapsed + angle * i)
		var book_position = self.__orbiting_books[i].position 
		
		var destination_position = self.global_position + book_offset
		
		self.__orbiting_books[i].position = book_position.move_toward(
			destination_position, 
			200.0 * delta
		)


func __handle_stunned(delta):
	self.__stunned_time_remaining = max(0.0, self.__stunned_time_remaining - delta)


func add_book_to_orbit(book):
	if self.has_max_books():
		return
	
	self.__orbiting_books.append(book)
	self.__orbiting_book_colors.append(book.color)


func remove_book_from_orbit(book):
	var index = self.__orbiting_books.find(book)
	self.__orbiting_books.remove(index)
	self.__orbiting_book_colors.remove(index)


func pop_book():
	return self.__orbiting_books.pop_back()


func has_orbiting():
	return self.__orbiting_books.size() > 0


func stun(time):
	self.__stunned_time_remaining = max(self.__stunned_time_remaining, time)


func is_stunned():
	return self.__stunned_time_remaining > 0.0


func has_max_books():
	return self.__orbiting_books.size() == self.max_books


func get_book_colors():
	return self.__orbiting_book_colors


func remove_books_for_color(color, is_equal):
	var new_books = []
	var removed_books = []
	
	for book in self.__orbiting_books:
		if (book.color == color) == is_equal:
			removed_books.append(book)
		else:
			new_books.append(book)
	
	if new_books.size() == self.__orbiting_books.size():
		return
	
	self.__orbiting_books = new_books
	self.__orbiting_book_colors = []
	for book in self.__orbiting_books:
		self.__orbiting_book_colors.append(book.color)
	
	return removed_books
