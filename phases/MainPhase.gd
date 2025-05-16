extends Node


func start_phase(gameboard) -> void:
	print("[MainPhase] start_phase")
	var player_hand = gameboard.get_node_or_null("Player1/PlayerHand")
	var player_board = gameboard.get_node_or_null("PlayerBoard")
	if not player_hand or not player_board:
		push_error("MainPhase: Missing PlayerHand or PlayerBoard")
	else:
		var cards_played = 0
		for card in player_hand.get_children():
			if _can_play_card(card, player_board) and cards_played < 2:
				print("[Main] Player plays %s" % card.name)
				player_hand.remove_child(card)
				player_board.add_child(card)
				cards_played += 1
		if cards_played < 2:
			var lvl1 = _find_level_1_card_on_board(player_board)
			if lvl1:
				var up = _upgrade_card(lvl1)
				if up:
					print("[Main] Player upgrades %s" % up.name)
					player_board.remove_child(lvl1)
					player_board.add_child(up)
					cards_played += 1

	print("[MainPhase] AI actions")
	var ai_hand = gameboard.get_node_or_null("Player2/PlayerHand")
	var ai_board = gameboard.get_node_or_null("EnemyBoard")
	if not ai_hand or not ai_board:
		push_error("MainPhase: Missing AIHand or EnemyBoard")
	else:
		var ai_played = 0
		for card in ai_hand.get_children():
			if _can_play_card(card, ai_board) and ai_played < 2:
				print("[Main] AI plays %s" % card.name)
				ai_hand.remove_child(card)
				ai_board.add_child(card)
				ai_played += 1
		if ai_played < 2:
			var ai_lvl1 = _find_level_1_card_on_board(ai_board)
			if ai_lvl1:
				var ai_up = _upgrade_card(ai_lvl1)
				if ai_up:
					print("[Main] AI upgrades %s" % ai_up.name)
					ai_board.remove_child(ai_lvl1)
					ai_board.add_child(ai_up)

	print("[MainPhase] Transition to CombatPhase")
	PhaseManager.force_phase(preload("res://phases/CombatPhase.gd"))



func _can_play_card(card: Node, board: Node) -> bool:
	return board.get_child_count() < 5

func _find_level_1_card_on_board(board: Node) -> Node:
	for card in board.get_children():
		if card.has_method("get_level") and card.get_level() == 1:
			return card
	return null

func _upgrade_card(level_1_card: Node) -> Node:
	if not level_1_card:
		push_error("Upgrade: level_1_card is null")
		return null
	var type = level_1_card.get_card_type()
	var next = level_1_card.get_level() + 1
	print("[Upgrade] %s -> level %d" % [type, next])
	var data = _load_upgraded_card_data(type, next)
	if data.size() == 0:
		push_warning("No data for upgraded %s lvl%d" % [type, next])
		return null
	return CardLoader.load_card_data(data)

func _load_upgraded_card_data(card_type: String, level: int) -> Dictionary:
	# Replace this with real JSON loading if needed
	var all = preload("res://data/card_database.json")
	for c in all:
		if c["card_type"] == card_type and int(c["level"]) == level:
			return c
	return {}
