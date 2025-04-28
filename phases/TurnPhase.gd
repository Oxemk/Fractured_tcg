extends Node
class_name TurnPhase

var current_player: int = 1

func start_phase(gameboard) -> void:
	_begin_turn(gameboard)

func _begin_turn(gameboard) -> void:
	print("Player %d turn." % current_player)
	# (turn UI, allow attacks, etc.)
	# After turn:
	_end_turn(gameboard)

func _end_turn(gameboard) -> void:
	current_player = 3 - current_player
	gameboard.switch_to_phase(preload("res://phases/VictoryPhase.gd").new())
