extends Node
class_name dice_state

const MAX_DIE_VALUE = 6


export var size: int = 6 
export var emit_on_change: bool = false

class die_state: 
	var value: int
	var selected: bool
	var disabled: bool
	
	func _init( value: int ) -> void:
		self.value = value
		self.selected = false
		self.disabled = false


var __selected: Array = []
var __selected_values: Array = []
var __values: Array = []

var __dice: Array = []

func _emit_die_changed( index: int ) -> void:
	if !self.emit_on_change:
		return
	
	event.emit_signal( 
		"on_die_state_change", 
		index, 
		self.__dice[ index ].value, 
		self.__dice[ index ].selected, 
		self.__dice[ index ].disabled
	)


func _random_die_value() -> int:
	return randi() % MAX_DIE_VALUE + 1


func disable_all( state: bool ) -> void:
	for index in range( self.size ):
		self.disable_at( index, state )


func disable_at( index: int, state: bool ) -> void:
	self.__dice[ index ].disabled = state
	if state: 
		self.__dice[ index ].selected = false
	
		self.__selected_values.clear()
		for index in range( self.size ):
			if self.__dice[ index ].selected:
				self.__selected_values.append( self.__dice[ index ].value )
	
	self._emit_die_changed( index )


func disable_selected() -> void:
	for index in range( self.size ):
		if self.__dice[ index ].selected:
			self.disable_at( index, true )


func get_selected_at( index: int ) -> bool:
	return self.__dice[ index ].selected


func get_selected_values() -> Array: 
	return self.__selected_values


func get_value_at( index: int ) -> int:
	return self.__dice[ index ].value


func reroll_at( index: int ) -> void:
	self.__dice[ index ].value = self._random_die_value()
	self._emit_die_changed( index )


func reroll_unselected() -> void:
	for index in range( self.size ):
		if !self.__dice[ index ].selected:
			self.reroll_at( index )


func reset() -> void:
	self.__dice.clear()
	self.__selected_values.clear()
	
	for index in range( self.size ):
		self.__dice.append( die_state.new( self._random_die_value() ) )
		self._emit_die_changed( index )


func select_all( state: bool ) -> void:
	for index in range( self.size ):
		self.select_at( index, state )


func select_at( index: int, state: bool ) -> void:
	self.__dice[ index ].selected = state
	
	self.__selected_values.clear()
	for index in range( self.size ):
		if self.__dice[ index ].selected:
			self.__selected_values.append( self.__dice[ index ].value )
	
	self._emit_die_changed( index )

