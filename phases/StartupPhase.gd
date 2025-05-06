extends Node
class_name StartupPhase

func start_phase(gameboard) -> void:
	# Filter Level-1 from raw deck
	var lvl1 = gameboard.player_deck.filter(func(d): return d.get("level", 0) == 1)
	if lvl1.size() == 0:
		push_error("ERROR: No Level-1 cards!")
	lvl1.shuffle()

	# Draw up to 5
	var draw_count = min(5, lvl1.size())
	var draw = lvl1.slice(0, draw_count)
	for d in draw:
		gameboard.player_deck.erase(d)

	# PvP vs AI?
	var is_pvp = gameboard.config.get("game_type", "pvp") == "pvp"
	var mode   = gameboard.config.get("mode", "duelist").to_lower()

	if is_pvp:
		var hand_path = "Player1/PlayerHand"
		var hand = gameboard.get_node_or_null(hand_path)
		if not hand:
			push_warning("StartupPhase: PlayerHand not found at '%s'" % hand_path)
		for d in draw:
			var c = CardLoader.load_card_data(d)
			if c and hand:
				hand.add_child(c)
			elif not c:
				push_error("Failed to instantiate PvP card: %s" % d)
	else:
		# AI auto-placement
		for i in range(draw.size()):
			var c = CardLoader.load_card_data(draw[i])
			if not c:
				push_error("Failed to instantiate AI startup card: %s" % draw[i])
				continue

			match mode:
				"duelist":
					_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", c)
				"bodyguard":
					_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", c) if i == 0 else null
					_add_to_zone(gameboard, "PlayerBoard/bodyguard_zone", c) if i == 1 else null
				"commander":
					_add_to_zone(gameboard, "PlayerBoard/deckmaster_row", c)   if i == 0 else null
					_add_to_zone(gameboard, "PlayerBoard/bodyguard_zone", c)   if i == 1 else null
					_add_to_zone(gameboard, "PlayerBoard/troop_slot1", c)      if i == 2 else null

	# Reinsert unused lvl1 and reshuffle
	var unused = lvl1.slice(draw_count, lvl1.size())
	gameboard.player_deck += unused
	gameboard.player_deck.shuffle()

	# Next: Draw Phase
	gameboard.switch_to_phase(preload("res://phases/DrawPhase.gd").new())


# Helper to safely add a card to a zone path on the gameboard
func _add_to_zone(gameboard, path: String, card: Node) -> void:
	var zone = gameboard.get_node_or_null(path)
	if zone:
		zone.add_child(card)
	else:
		push_warning("StartupPhase: Zone not found at '%s'" % path)
