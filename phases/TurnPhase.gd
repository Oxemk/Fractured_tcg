extends Node
class_name TurnPhase

func start_phase(gameboard) -> void:
	# E.g. switch current player, reset actions, then:
	gameboard.switch_to_phase(preload("res://phases/DrawPhase.gd").new())
