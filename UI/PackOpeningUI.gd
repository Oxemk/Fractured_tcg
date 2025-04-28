extends Control

func _ready():
	# Ensure the button exists
	if has_node("OpenPackButton"):
		var button := $OpenPackButton
		button.pressed.connect(_on_OpenPackButton_pressed)
	else:
		push_error("OpenPackButton not found!")

func _on_OpenPackButton_pressed():
	# Simulate getting cards from a pack manager
	var opened_cards = [
		{"name": "Knight of Dawn", "rarity": "Common"},
		{"name": "Elder Mage", "rarity": "Rare"},
		{"name": "Spectral Warlord", "rarity": "Epic"}
	]
	display_opened_cards(opened_cards)

func display_opened_cards(cards: Array):
	var container := $OpenedCardsContainer
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	for card in cards:
		var label := Label.new()
		label.text = "%s (%s)" % [card["name"], card["rarity"]]
		container.add_child(label)
		print("Opened card: %s (Rarity: %s)" % [card["name"], card["rarity"]])
