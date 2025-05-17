extends Node
class_name DrawPhase

func start_phase(gameboard):
	print("[DrawPhase] start_phase")
	gameboard.draw_cards(1, true)
	gameboard.draw_cards(1, false)
	print("[DrawPhase] end, forcing StandbyPhase")
	PhaseManager.force_phase(preload("res://phases/StandbyPhase.gd"))
