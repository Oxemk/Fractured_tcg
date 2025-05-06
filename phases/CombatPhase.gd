extends Node
class_name CombatPhase

func start_phase(gameboard) -> void:
	gameboard.enable_combat_ui()
	# After combat action is done:
	gameboard.switch_to_phase(preload("res://phases/EndPhase.gd").new())
