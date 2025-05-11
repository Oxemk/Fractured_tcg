extends Node
class_name TurnPhase

func start_phase(gameboard) -> void:
	# Example: rotate active player, reset per-turn flags, etc.
	gameboard.current_player = 3 - gameboard.current_player
	# After swapping players, go into the draw phase
	gameboard._switch_to_phase(preload("res://phases/DrawPhase.gd").new())
