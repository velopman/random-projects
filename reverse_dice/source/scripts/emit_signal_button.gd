extends Button

export var signal_name = ""

func _on_button_up():
	event.emit_signal( self.signal_name )
