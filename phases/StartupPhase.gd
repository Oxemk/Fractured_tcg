extends Node
class_name StartupPhase

func start_phase(gameboard) -> void:
	# 1. Filter out only Level-1 cards
	var lvl1 = gameboard.player_deck.filter(func(c) -> bool:
		return c.level == 1
	)
	# 2. Shuffle them
	lvl1.shuffle()
	# 3. Draw up to 5 cards
	var draw_count = min(5, lvl1.size())
	var draw = lvl1.slice(0, draw_count)
	
	# 4. Place them based on mode
	match gameboard.config.mode:
		"duelist":
			gameboard.player_zone.get_node("DeckmasterZone").add_child(draw[0])
		"bodyguard":
			gameboard.player_zone.get_node("DeckmasterZone").add_child(draw[0])
			gameboard.player_zone.get_node("BodyguardZone").add_child(draw[1])
		"commander":
			gameboard.player_zone.get_node("DeckmasterZone").add_child(draw[0])
			gameboard.player_zone.get_node("BodyguardZone").add_child(draw[1])
			gameboard.player_zone.get_node("TroopZone").add_child(draw[2])
	
	# 5. Remove drawn cards from the deck, then put everything back & reshuffle
	for c in draw:
		gameboard.player_deck.erase(c)
	gameboard.player_deck += lvl1
	gameboard.player_deck.shuffle()
	
	# 6. Advance to the next phase
	var turn_phase = preload("res://phases/TurnPhase.gd").new()
	gameboard.switch_to_phase(turn_phase)
