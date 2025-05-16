extends Node
class_name DrawPhase

func start_phase(gameboard) -> void:
	print("[DrawPhase] start_phase")
	gameboard.draw_cards(1, true)  # Player 1
	gameboard.draw_cards(1, false) # Player 2 (AI or second player)
	print("[DrawPhase] Transition to MainPhase")
	PhaseManager.force_phase(preload("res://phases/MainPhase.gd"))
