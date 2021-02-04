extends Node
class_name ability_state


export(Array, Resource) var abilities


var __enabled = []

func _emit_ability_changed( index: int ) -> void:
	var ability = self.abilities[ index ]
	
	event.emit_signal( 
		"on_ability_state_changed",
		index,
		ability.name,
		self.__enabled[ index ]
	)

func reset():
	self.__enabled.clear()
	
	for index in range( self.abilities.size() ):
		self.__enabled.append( false )
		self._emit_ability_changed( index )


func enable_abilities( values: Array ) -> void:
	for index in range( self.abilities.size() ):
		self.__enabled[ index ] = self.abilities[ index ].is_requirement_met( values )
		self._emit_ability_changed( index )
