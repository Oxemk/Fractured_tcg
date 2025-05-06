extends Node
class_name MainPhase

func start_phase(gameboard) -> void:
	# Your main-phase logic here (play cards, etc.)
	# Then:
	gameboard.switch_to_phase(preload("res://phases/CombatPhase.gd").new())
