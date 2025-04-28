extends Node
class_name VictoryPhase

func start_phase(gameboard) -> void:
	if gameboard.check_victory():
		gameboard.display_victory()
	else:
		gameboard.switch_to_phase(preload("res://phases/TurnPhase.gd").new())
