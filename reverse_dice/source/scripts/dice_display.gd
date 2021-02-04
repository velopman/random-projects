extends Button


export var index = 0;


func _ready() -> void: 
	event.connect( "on_die_state_change", self, "_on_die_state_change" )


func _on_button_up() -> void:
	event.emit_signal( "on_die_pressed", self.index )


func _on_die_state_change( index, value, selected, disabled ) -> void:
	if self.index != index:
		return
	
	self.text = "%d%s" % [ value, "S" if selected else "U" ]
	self.disabled = disabled
