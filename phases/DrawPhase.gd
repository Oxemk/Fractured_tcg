extends Node
class_name DrawPhase

func start_phase(gameboard) -> void:
	print("[DrawPhase] start_phase")
	gameboard.draw_cards(1, true)
	gameboard.draw_cards(1, false)
	print("[DrawPhase] Transition to MainPhase")
	PhaseManager.force_phase(preload("res://phases/MainPhase.gd"))
