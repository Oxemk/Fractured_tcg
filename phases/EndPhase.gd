extends Node
class_name endphase

var gameboard: Node

func start_phase(gameboard_instance: Node) -> void:
	print("[EndPhase] start_phase")
	gameboard = gameboard_instance

	_resolve_end_of_turn_effects(gameboard.PlayerBoard)
	_resolve_end_of_turn_effects(gameboard.EnemyBoard)

	_cleanup_after_turn(gameboard.PlayerBoard)
	_cleanup_after_turn(gameboard.EnemyBoard)

	if _check_victory_condition(gameboard.PlayerBoard):
		print("[EndPhase] Player wins!")
		_end_game("Player Wins!")
		return
	elif _check_victory_condition(gameboard.EnemyBoard):
		print("[EndPhase] AI wins!")
		_end_game("AI Wins!")
		return

	print("[EndPhase] Transition to next phase")
	_transition_to_next_phase()

func _resolve_end_of_turn_effects(board: Node) -> void:
	for card in board.get_children():
		if card.has_method("resolve_end_of_turn_effects"):
			card.resolve_end_of_turn_effects()

func _cleanup_after_turn(board: Node) -> void:
	for card in board.get_children():
		if card.has_method("cleanup_after_turn"):
			card.cleanup_after_turn()

func _check_victory_condition(board: Node) -> bool:
	for card in board.get_children():
		if card.has_method("get_role") and card.get_role() == "deckmaster":
			if card.get_hp() <= 0:
				return true
	return false

func _end_game(winner_message: String) -> void:
	print("[EndPhase] " + winner_message)
	gameboard.show_game_over_screen(winner_message)
	# Optionally disable inputs here

func _transition_to_next_phase() -> void:
	# Force the PhaseManager to switch to DrawPhase
	PhaseManager.force_phase(preload("res://phases/DrawPhase.gd"))
