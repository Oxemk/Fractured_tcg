extends Node
class_name StandbyPhase

func start_phase(gameboard: Node) -> void:
	print("[StandbyPhase] start_phase")
	# TODO: iterate through any cards/effects that trigger here:
	# e.g. for card in gameboard.PlayerBoard.get_children(): if card.has_method("on_standby"): card.on_standby()
	# For now, just move on to Main Phase:
	gameboard._switch_to_phase(preload("res://phases/MainPhase.gd").new())
