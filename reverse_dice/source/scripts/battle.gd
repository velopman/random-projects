extends Node2D


var participants = []
var current_participant = 0

var stages = [
	funcref( self, "_start_phase" ),
	funcref( self, "_rolling_phase" ),
	funcref( self, "_damage_phase" ),
	funcref( self, "_clean_phase" ),
]
var current_stage = 0


func _ready() -> void:
	self.participants.append( 
		player_turn_controller.new( 
			$player/ability_state,
			$player/dice_state
		) 
	)

func _process(delta):
	var participant = self.participants[ self.current_participant ] 
	if participant.next_phase() || self.stages[ self.current_stage ].call_func( participant ): 
		self._advance_stage( participant )


func _advance_stage( participant: turn_controller ) -> void:
	participant.set_next_phase( false )
	# TODO: check if battle over
	
	self.current_stage = ( self.current_stage + 1 ) % self.stages.size()
	
	if self.current_stage == 0:
		self.current_participant = ( self.current_participant + 1 ) % self.participants.size()
	
	event.emit_signal(
		"on_battle_state_changed", 
		self.current_participant, 
		self.current_stage
	)


func _clean_phase( participant: turn_controller ) -> bool:
	return participant.handle_clean_phase()


func _damage_phase( participant: turn_controller ) -> bool:
	return participant.handle_damage_phase()


func _rolling_phase( participant: turn_controller ) -> bool:
	return participant.handle_rolling_phase()


func _start_phase( participant: turn_controller ) -> bool:
	return participant.handle_start_phase()


# participants
	# 1 x player
	# n x enemies


# flow
	# player takes a turn
	# for each enemy
		# enemy turn


# players/enemy turn
	# rolling phase
		# select dice to keep
		# re-roll remaing
		# repeated 2x
	# damage phase
		# select dice to use
		# select attack to make
		# select target (if required)

# dice_state
# damage_state

# example: 
	# basic attack: 2x6, 1 damage, 1 target
	# whirlwind: 3x4, 1 damage, all 
	# cripling strike: 1x1;1x2;1x3;1x4, 4 damage, 1 target


# turn_controller 
	# dice_state
	
	# initialize
		# randomly populate initial state for dice ( up to count )
		# (player) update UI to represent dice state
	
	# rolling phase
		# player
			# select die values, update an array of indecies of state array to keep
			# re-roll, loops over array if index != indicies, regenerate value
		# enemy
			# determine closest damage state to target (i.e 3x4 when it had 2x4 would aim to re-roll a 4) 
			# re-roll redundant die
	
	# damage phase
		# player
			# select die values
			# select attack that corresponds with values
			# select target ( if required )
