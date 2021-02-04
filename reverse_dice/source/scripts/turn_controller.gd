class_name turn_controller

export var reroll_count = 2


var _ability_state_instance: ability_state
var _dice_state_instance: dice_state

var _reroll_remaining: int = 0
var _next_phase: bool = false


func _init( ability_state_instance: ability_state, dice_state_instance: dice_state ) -> void:
	self._ability_state_instance = ability_state_instance
	self._dice_state_instance = dice_state_instance


func handle_clean_phase() -> bool:
	self._dice_state_instance.select_all( false )
	return false 


func handle_damage_phase() -> bool:
	return false


func handle_rolling_phase() -> bool:
	return false


func handle_start_phase() -> bool:
	self._ability_state_instance.reset()
	self._dice_state_instance.reset()
	self._reroll_remaining = self.reroll_count
	
	return true


func next_phase() -> bool:
	return self._next_phase


func set_next_phase( next_phase: bool = true ) -> void:
	self._next_phase = next_phase


func _reroll_unselected() -> void:
	if _reroll_remaining <= 0:
		return
	
	self._dice_state_instance.reroll_unselected()
	
	self._reroll_remaining -= 1


func _select_at( index: int, state: bool ) -> void:
	self._dice_state_instance.select_at( index, state )


func _toggle_selected_at( index: int ) -> void:
	var current_state: bool = self._dice_state_instance.get_selected_at( index )
	self._dice_state_instance.select_at( index, !current_state )
	self._ability_state_instance.enable_abilities(
		self._dice_state_instance.get_selected_values()
	)
