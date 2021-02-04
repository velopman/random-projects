extends Button


export(int) var index = 0


func _ready() -> void: 
	event.connect( "on_ability_state_changed", self, "_on_ability_state_changed" )


func _on_button_up() -> void:
	event.emit_signal( "on_ability_pressed", self.index )


func _on_ability_state_changed( index, name, enabled ) -> void:
	if self.index != index:
		return
	
	self.text = name
	self.disabled = !enabled
