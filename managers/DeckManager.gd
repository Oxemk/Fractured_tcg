extends Node

var decks: Array = []  # User decks
var ai_decks: Array = []  # AI decks (loaded from a static file)
var selected_deck_index: int = -1

func _ready() -> void:
	load_decks()
	load_ai_decks()

# Create or replace a user deck
func create_deck(deck: Dictionary) -> void:
	if !deck.has("name") or !deck.has("cards") or !deck.has("mode"):
		print("Error: The deck is missing required fields.")
		return

	# Add or replace deck at the selected index
	if selected_deck_index >= 0 and selected_deck_index < decks.size():
		decks[selected_deck_index] = deck.duplicate()
	else:
		decks.append(deck.duplicate())
		selected_deck_index = decks.size() - 1

	save_decks()

# Get user deck by index
func get_deck(index: int) -> Dictionary:
	return decks[index] if index >= 0 and index < decks.size() else {}

# Get the currently selected user deck
func get_selected_deck() -> Dictionary:
	return get_deck(selected_deck_index)

# Set the currently selected user deck by index
func set_selected_deck(index: int) -> void:
	if index >= 0 and index < decks.size():
		selected_deck_index = index

# Get the total count of user decks
func get_deck_count() -> int:
	return decks.size()

# Save user decks to persistent storage
func save_decks() -> void:
	DataUtils.save_data("user://decks.json", decks)
	print("User decks saved successfully.")

# Load user decks
func load_decks() -> void:
	var data = DataUtils.load_data("user://decks.json")
	if data is Array:
		decks = data.duplicate()
		print("User decks loaded successfully.")
	else:
		decks = []
		selected_deck_index = -1
		print("No saved user decks found or failed to load.")

# Load AI decks (from static file)
func load_ai_decks() -> void:
	var data = DataUtils.load_data("res://data/decks.json")
	if data is Array:
		ai_decks = data.duplicate()
		print("AI decks loaded successfully.")
	else:
		ai_decks = []
		print("No AI decks found or failed to load.")
