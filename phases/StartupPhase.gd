extends Node
class_name StartupPhase

func start_phase(gameboard: Node, is_player1: bool = true) -> void:
	print("[StartupPhase] start_phase – is_player1 = %s" % is_player1)

	# 1️⃣ Determine deck for this side
	var deck: Array
	if is_player1:
		deck = gameboard.p1_deck
	else:
		if gameboard.game_mode == gameboard.GameMode.PVP:
			deck = gameboard.p2_deck
		else:
			deck = gameboard.ai_deck
	print("[StartupPhase] Initial deck size: %d" % deck.size())

	# 2️⃣ Collect level-1 characters
	var id_data_pairs: Array = []
	for cid in deck.duplicate():
		var data: Dictionary = gameboard._load_card_json(cid)
		if data.size() == 0:
			push_warning("[StartupPhase] Missing data for ID %s" % cid)
			continue
		if data.get("card_type", "") == "Character" and int(data.get("level", 0)) == 1:
			id_data_pairs.append({"id": cid, "data": data})
		else:
			push_warning("[StartupPhase] Skipping non-level-1 card %s" % cid)
	print("[StartupPhase] Found %d lvl-1 chars" % id_data_pairs.size())
	if id_data_pairs.size() == 0:
		push_error("[StartupPhase] No Level-1 character cards found!")
		return

	# 3️⃣ Shuffle & draw up to 5
	id_data_pairs.shuffle()
	var draw_count: int = min(5, id_data_pairs.size())
	var drawn: Array = id_data_pairs.slice(0, draw_count)
	print("[StartupPhase] Drawing %d cards" % draw_count)

	# 4️⃣ Remove from deck
	for pair in drawn:
		deck.erase(pair["id"])
	print("[StartupPhase] Deck size after removal: %d" % deck.size())

	# 5️⃣ Deploy: hand for player1 or zones for player2/AI
	var mode: String = "duelist"
	if gameboard.config and typeof(gameboard.config) == TYPE_DICTIONARY and gameboard.config.has("mode"):
		mode = str(gameboard.config["mode"]).to_lower()
	print("[StartupPhase] Deploy mode: %s" % mode)

	if is_player1 and gameboard.game_mode == gameboard.GameMode.PVP:
		print("[StartupPhase] Adding to Player1 hand")
		for pair in drawn:
			var card = sCardLoader.load_card_data(pair["data"])
			if card:
				gameboard.PlayerHand.add_child(card)
			else:
				push_error("[StartupPhase] Failed to load P1 card %s" % pair["id"])
	else:
		print("[StartupPhase] Adding to Player2/AI board")
		for i in range(drawn.size()):
			var card = sCardLoader.load_card_data(drawn[i]["data"])
			if not card:
				push_error("[StartupPhase] Failed to load AI card %s" % drawn[i]["id"])
				continue
			match mode:
				"duelist": _add_to_zone(gameboard, "PlayerBoard/deckmaster_row", card)
				"bodyguard":
					if i == 0:
						_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", card)
					elif i == 1:
						_add_to_zone(gameboard, "PlayerBoard/bodyguard_zone", card)
				"commander":
					if i == 0:
						_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", card)
					elif i == 1:
						_add_to_zone(gameboard, "PlayerBoard/bodyguard_zone", card)
					elif i == 2:
						_add_to_zone(gameboard, "PlayerBoard/troop_slot1", card)

	# 6️⃣ Return drawn IDs & shuffle deck
	for pair in drawn:
		deck.append(pair["id"])
	deck.shuffle()
	print("[StartupPhase] Deck reshuffled; size now %d" % deck.size())

	# 7️⃣ Draw opening hand
	gameboard.draw_cards(5, is_player1)
	print("[StartupPhase] Opening draw done for is_player1 = %s" % is_player1)

	# ✔️ End of StartupPhase – now wait for Draw button
	print("[StartupPhase] Waiting for player to manually start DrawPhase")
	PhaseManager.pause()

# 🔧 Helper to place a card into a zone
func _add_to_zone(gameboard: Node, path: String, card: Node) -> void:
	var zone = gameboard.get_node_or_null(path)
	if zone:
		zone.add_child(card)
		print("[StartupPhase] Added %s to %s" % [card.name, path])
	else:
		push_warning("[StartupPhase] Zone not found: %s" % path)
