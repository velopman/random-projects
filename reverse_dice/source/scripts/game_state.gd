extends Label


func _ready():
	event.connect( "on_battle_state_changed", self, "_on_battle_state_changed" )


func _on_battle_state_changed( current_participant, current_stage ):
	self.text = "current_participant: %d\ncurrent_stage: %d" % [ current_participant, current_stage ]
