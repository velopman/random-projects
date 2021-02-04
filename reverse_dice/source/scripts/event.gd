extends Node

signal on_ability_pressed( index )
signal on_ability_state_changed( index, name, enabled )
signal on_battle_state_changed( current_participant, current_stage )
signal on_die_pressed( index )
signal on_die_state_change( index, value, selected, disabled )
signal on_next_phase_pressed()
signal on_reroll_pressed()
