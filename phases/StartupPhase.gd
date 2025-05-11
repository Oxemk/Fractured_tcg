extends Node
class_name StartupPhase

func start_phase(gameboard) -> void:
	var id_data_pairs := []
	
	# Filter Level 1 character cards from the player's deck
	for id in gameboard.player_deck:
		var data = gameboard._load_card_json(id)
		if data.size() > 0:
			if data["card_type"] == "Character" and int(data.get("level", 0)) == 1:
				id_data_pairs.append({ "id": id, "data": data })
			else:
				push_warning("StartupPhase: Skipping non-character or non-level-1 card with ID %s" % id)
		else:
			push_warning("StartupPhase: Missing data for card ID %s" % id)
	
	if id_data_pairs.is_empty():
		push_error("ERROR: No Level-1 character cards found!")
		return
	
	# Continue as usual with the rest of the code...


	# Shuffle the Level-1 cards
	id_data_pairs.shuffle()
	
	# Draw 5 cards (limit to 5 if less than 5 available)
	var draw_count = min(5, id_data_pairs.size())
	var drawn_pairs = id_data_pairs.slice(0, draw_count)

	# Remove drawn cards from the player's deck
	for pair in drawn_pairs:
		gameboard.player_deck.erase(pair.id)

	# Determine the game mode (PvP, Duelist, Bodyguard, Commander)
	var is_pvp = gameboard.config.get("game_type", "pvp") == "pvp"
	var mode = gameboard.config.get("mode", "duelist").to_lower()

	# Place cards based on game mode
	if is_pvp:
		# PvP Mode: Add each drawn card to the player's hand
		var hand = gameboard.get_node_or_null("Player1/PlayerHand")
		if not hand:
			push_warning("StartupPhase: PlayerHand not found at 'Player1/PlayerHand'")
		
		# Add each drawn card to the player's hand
		for pair in drawn_pairs:
			var c = CardLoader.load_card_data(pair.data)
			if c and hand:
				hand.add_child(c)
			else:
				push_error("StartupPhase: Failed to instantiate PvP card %s" % pair.id)
	else:
		# Non-PvP Mode: Place the drawn cards in appropriate zones based on the game mode
		for i in range(drawn_pairs.size()):
			var pair = drawn_pairs[i]
			var c = CardLoader.load_card_data(pair.data)
			if not c:
				push_error("StartupPhase: Failed to instantiate AI card %s" % pair.id)
				continue
			
			# Add cards to specific zones based on mode
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

	# Return the drawn cards back to the deck and shuffle
	for pair in drawn_pairs:
		gameboard.player_deck.append(pair.id)

	# Shuffle the deck
	gameboard.player_deck.shuffle()

	# Draw 5 more cards for the player from the shuffled deck
	gameboard.draw_cards(5, true)  # Draw 5 cards for the player (true indicates it's for the player)

	# Move to the next phase (Draw Phase)
	gameboard._switch_to_phase(DrawPhase.new())

# Helper function to add a card to a specified zone
func _add_to_zone(gameboard: Node, path: String, card: Node) -> void:
	var zone = gameboard.get_node_or_null(path)
	if zone:
		zone.add_child(card)
	else:
		push_warning("StartupPhase: Zone not found at '%s'" % path)
