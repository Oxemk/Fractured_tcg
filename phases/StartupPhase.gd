# --- MainPhase.gd ---
extends Node
class_name MainPhase

var gameboard: GameBoard = null

func start_phase(board: Node) -> void:
	gameboard = board
	print("[MainPhase] start_phase - Owner:", gameboard.current_turn_owner)

	if gameboard.current_turn_owner == gameboard.TurnOwner.PLAYER1:
		_enter_player_main()
	else:
		await _enter_ai_main()

func _enter_player_main() -> void:
	# Disable phase UI buttons
	gameboard.btn_main1.disabled = true
	gameboard.btn_battle.disabled = true
	gameboard.btn_main2.disabled = true
	gameboard.btn_end.disabled = true

	# Player plays up to 2 cards or performs an upgrade
	var player_hand = gameboard.get_node_or_null("Player1/PlayerHand")
	var player_board = gameboard.get_node_or_null("PlayerBoard")
	if player_hand and player_board:
		var cards_played := 0
		# Play cards
		for card in player_hand.get_children():
			if cards_played < 2 and _can_play_card(card, player_board):
				player_hand.remove_child(card)
				player_board.add_child(card)
				cards_played += 1
		# Try upgrade if fewer than 2 plays
		if cards_played < 2:
			var lvl1 = _find_level_1_card_on_board(player_board)
			if lvl1:
				var up = _upgrade_card(lvl1)
				if up:
					player_board.remove_child(lvl1)
					player_board.add_child(up)
	else:
		push_error("MainPhase: Missing PlayerHand or PlayerBoard")

	# Enable End Turn button
	gameboard.btn_end.disabled = false
	gameboard.btn_end.connect("pressed", Callable(self, "_on_player_end"))
	print("[MainPhase] Player main done, waiting for end-phase input")

func _on_player_end() -> void:
	# Cleanup and notify phase complete
	gameboard.btn_end.disconnect("pressed", Callable(self, "_on_player_end"))
	gameboard.btn_end.disabled = true
	print("[MainPhase] Player ended turn")
	PhaseManager.notify_phase_complete()

func _enter_ai_main() -> void:
	print("[MainPhase] AI actions start")
	var ai_hand = gameboard.get_node_or_null("Player2/PlayerHand")
	var ai_board = gameboard.get_node_or_null("EnemyBoard")
	if ai_hand and ai_board:
		var ai_played := 0
		for card in ai_hand.get_children():
			if ai_played < 2 and _can_play_card(card, ai_board):
				ai_hand.remove_child(card)
				ai_board.add_child(card)
				ai_played += 1
		if ai_played < 2:
			var ai_lvl1 = _find_level_1_card_on_board(ai_board)
			if ai_lvl1:
				var ai_up = _upgrade_card(ai_lvl1)
				if ai_up:
					ai_board.remove_child(ai_lvl1)
					ai_board.add_child(ai_up)
	else:
		push_error("MainPhase: Missing AIHand or EnemyBoard")

	# Simulate AI thinking
	await get_tree().create_timer(1.0).timeout
	print("[MainPhase] AI actions done")
	PhaseManager.notify_phase_complete()

func _can_play_card(card: Node, board: Node) -> bool:
	return board.get_child_count() < 5

func _find_level_1_card_on_board(board: Node) -> Node:
	for card in board.get_children():
		if card.has_method("get_level") and card.get_level() == 1:
			return card
	return null

func _upgrade_card(level_1_card: Node) -> Node:
	if not level_1_card:
		return null
	var type = level_1_card.get_card_type()
	var next_lvl = level_1_card.get_level() + 1
	# Load upgraded card data from CardDatabase
	var key = type + "_lvl" + str(next_lvl)
	var data = CardDatabase.cards.get(key, {})
	if data.size() == 0:
		push_warning("No data for upgraded %s level %d" % [type, next_lvl])
		return null
	return CardLoader.load_card_data(data)
