extends Node
class_name EndPhase

func start_phase(gameboard) -> void:
	gameboard.cleanup_end_phase()
	if gameboard.check_victory():
		gameboard.switch_to_phase(preload("res://phases/VictoryPhase.gd").new())
	else:
		gameboard.switch_to_phase(preload("res://phases/TurnPhase.gd").new())
