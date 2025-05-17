extends Node
class_name StartupPhase

func start_phase(gameboard: Node, is_player1: bool = true) -> void:
	var deck: Array = gameboard.p1_deck if is_player1 else (gameboard.p2_deck if gameboard.game_mode == gameboard.GameMode.PVP else gameboard.ai_deck)
	var id_data_pairs: Array[Dictionary] = []

	# Step 1: Filter Level 1 Character cards
	for id in deck.duplicate():
		var data: Dictionary = gameboard._load_card_json(id)
		if data.size() == 0:
			push_warning("StartupPhase: Missing data for card ID %s" % id)
			continue

		if data.get("card_type", "") == "Character" and int(data.get("level", 0)) == 1:
			id_data_pairs.append({ "id": id, "data": data })
		else:
			push_warning("StartupPhase: Skipping non-character or non-level-1 card with ID %s" % id)

	if id_data_pairs.is_empty():
		push_error("StartupPhase: No Level-1 character cards found in deck!")
		return

	# Step 2: Shuffle and select up to 5 Level 1 Character cards
	id_data_pairs.shuffle()
	var draw_count: int = min(5, id_data_pairs.size())
	var drawn_pairs: Array[Dictionary] = id_data_pairs.slice(0, draw_count)

	# Step 3: Remove drawn cards from the deck
	for pair in drawn_pairs:
		deck.erase(pair["id"])

	# Step 4: Determine game mode
	var is_pvp: bool = gameboard.game_mode == gameboard.GameMode.PVP
	var mode: String = str(gameboard.config.get("mode", "duelist")).to_lower() if gameboard.has_method("config") else "duelist"

	# Step 5: Deploy cards
	if is_pvp and is_player1:
		var hand = gameboard.PlayerHand
		if not hand:
			push_warning("StartupPhase: PlayerHand not found")
		else:
			for pair in drawn_pairs:
				var card: Node = sCardLoader.load_card_data(pair["data"])
				if card:
					hand.add_child(card)
				else:
					push_error("StartupPhase: Failed to instantiate card %s" % pair["id"])
	else:
		for i in range(drawn_pairs.size()):
			var card: Node = sCardLoader.load_card_data(drawn_pairs[i]["data"])
			if not card:
				push_error("StartupPhase: Failed to instantiate AI card %s" % drawn_pairs[i]["id"])
				continue

			match mode:
				"duelist":
					_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", card)
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

	# Step 6: Return drawn cards to deck and shuffle
	for pair in drawn_pairs:
		deck.append(pair["id"])

	deck.shuffle()

	# Step 7: Draw 5 cards into hand
	gameboard.draw_cards(5, is_player1)

	# Step 8: Transition to Draw Phase

	PhaseManager.(preload("res://phases/DrawPhase.gd"))

# 🔧 Helper
func _add_to_zone(gameboard: Node, path: String, card: Node) -> void:
	var zone := gameboard.get_node_or_null(path)
	if zone:
		zone.add_child(card)
	else:
		push_warning("StartupPhase: Zone not found at '%s'" % path)
