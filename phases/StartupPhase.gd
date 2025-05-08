extends Node
class_name StartupPhase

func start_phase(gameboard) -> void:
	# First, build a list of (id, data) pairs so we can filter by level
	var id_data_pairs := []
	for id in gameboard.player_deck:
		var data = gameboard._load_card_json(id)
		if data.size() > 0:
			id_data_pairs.append({ "id": id, "data": data })
		else:
			push_warning("StartupPhase: Missing data for card ID %s" % id)

	# Filter for level-1 cards
	var lvl1_pairs = id_data_pairs.filter(func(pair):
		return int(pair.data.get("level", 0)) == 1
	)
	if lvl1_pairs.is_empty():
		push_error("ERROR: No Level-1 cards!")
		return

	# Shuffle and draw
	lvl1_pairs.shuffle()
	var draw_count = min(5, lvl1_pairs.size())
	var drawn_pairs = lvl1_pairs.slice(0, draw_count)

	# Remove drawn IDs from the deck
	for pair in drawn_pairs:
		gameboard.player_deck.erase(pair.id)

	# Determine mode
	var is_pvp = gameboard.config.get("game_type", "pvp") == "pvp"
	var mode   = gameboard.config.get("mode", "duelist").to_lower()

	if is_pvp:
		# PvP: add to player hand
		var hand = gameboard.get_node_or_null("Player1/PlayerHand")
		if not hand:
			push_warning("StartupPhase: PlayerHand not found at 'Player1/PlayerHand'")
		for pair in drawn_pairs:
			var c = CardLoader.load_card_data(pair.data)
			if c and hand:
				hand.add_child(c)
			else:
				push_error("StartupPhase: Failed to instantiate PvP card %s" % pair.id)
	else:
		# AI: place into zones based on mode
		for i in range(drawn_pairs.size()):
			var pair = drawn_pairs[i]
			var c = CardLoader.load_card_data(pair.data)
			if not c:
				push_error("StartupPhase: Failed to instantiate AI card %s" % pair.id)
				continue
			match mode:
				"duelist":
					_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", c)
				"bodyguard":
					if i == 0:
						_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", c)
					elif i == 1:
						_add_to_zone(gameboard, "PlayerBoard/bodyguard_zone", c)
				"commander":
					if i == 0:
						_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", c)
					elif i == 1:
						_add_to_zone(gameboard, "PlayerBoard/bodyguard_zone", c)
					elif i == 2:
						_add_to_zone(gameboard, "PlayerBoard/troop_slot1", c)

	# Reinsert unused level-1 IDs and reshuffle
	var unused_pairs = lvl1_pairs.slice(draw_count, lvl1_pairs.size())
	for pair in unused_pairs:
		gameboard.player_deck.append(pair.id)
	gameboard.player_deck.shuffle()

	# Move to the Draw phase
	gameboard.switch_to_phase(preload("res://phases/DrawPhase.gd").new())

func _add_to_zone(gameboard: Node, path: String, card: Node) -> void:
	var zone = gameboard.get_node_or_null(path)
	if zone:
		zone.add_child(card)
	else:
		push_warning("StartupPhase: Zone not found at '%s'" % path)
