# DrawPhase.gd
extends Node
class_name DrawPhase

func start_phase(gameboard) -> void:
	# Player draws
	gameboard.draw_cards(gameboard.draw_count_per_turn, true)
	# AI draws
	gameboard.draw_cards(gameboard.draw_count_per_turn, false)
	# Next phase
	gameboard.switch_to_phase(preload("res://phases/MainPhase.gd").new())
