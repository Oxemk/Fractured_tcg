extends Node
class_name EndPhase

var gameboard: Node

func start_phase(gameboard_instance: Node) -> void:
	print("[EndPhase] Starting End Phase")
	gameboard = gameboard_instance

	print("[EndPhase] Resolving end-of-turn effects")
	_resolve_end_of_turn_effects(gameboard.PlayerBoard)
	_resolve_end_of_turn_effects(gameboard.EnemyBoard)

	print("[EndPhase] Cleaning up turn state")
	_cleanup_after_turn(gameboard.PlayerBoard)
	_cleanup_after_turn(gameboard.EnemyBoard)

	if _check_victory_condition(gameboard.PlayerBoard):
		print("[EndPhase] Victory check: Player loses, AI wins")
		_end_game("AI Wins!")
		return
	elif _check_victory_condition(gameboard.EnemyBoard):
		print("[EndPhase] Victory check: AI loses, Player wins")
		_end_game("Player Wins!")
		return

	print("[EndPhase] No victory yet, transitioning to DrawPhase")
	_transition_to_next_phase()


func _resolve_end_of_turn_effects(board: Node) -> void:
	for card in board.get_children():
		if card.has_method("resolve_end_of_turn_effects"):
			print("[EndPhase] Resolving end-of-turn effects for card: %s" % card.name)
			card.resolve_end_of_turn_effects()


func _cleanup_after_turn(board: Node) -> void:
	for card in board.get_children():
		if card.has_method("cleanup_after_turn"):
			print("[EndPhase] Cleaning up card: %s" % card.name)
			card.cleanup_after_turn()


func _check_victory_condition(board: Node) -> bool:
	for card in board.get_children():
		if card.has_method("get_role") and card.get_role() == "deckmaster":
			var hp = card.get_hp() if card.has_method("get_hp") else 9999
			print("[EndPhase] Checking HP of deckmaster: %d" % hp)
			if hp <= 0:
				return true
	return false


func _end_game(winner_message: String) -> void:
	push_warning("[EndPhase] Game over: %s" % winner_message)
	gameboard.show_game_over_screen(winner_message)
	# Optional: Disable player interaction, stop timers, etc.


func _transition_to_next_phase() -> void:
	print("[EndPhase] Switching to DrawPhase")
	var next_phase = preload("res://phases/DrawPhase.gd").new()
	gameboard._switch_to_phase(next_phase)
