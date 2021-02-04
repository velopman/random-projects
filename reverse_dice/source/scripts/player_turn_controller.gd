extends turn_controller
class_name player_turn_controller

func _init( ability_state_instance: ability_state, dice_state_instance: dice_state ) \
	.( ability_state_instance, dice_state_instance ) -> void:
	event.connect( "on_die_pressed", self, "_toggle_selected_at" )
	event.connect( "on_reroll_pressed", self, "_reroll_unselected" )
	event.connect( "on_next_phase_pressed", self, "set_next_phase" )


func handle_clean_phase() -> bool:
	.handle_clean_phase()
	return true 


func handle_damage_phase() -> bool:
	return false


func handle_rolling_phase() -> bool:
	return self._reroll_remaining <= 0


func handle_start_phase() -> bool:
	return .handle_start_phase()


func _on_next_phase_pressed() -> void:
	self.next_phase = true
