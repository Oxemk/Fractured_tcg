# res://managers/DeckManager.gd
extends Node

var decks: Array = []
var selected_deck_index: int = -1

func _ready() -> void:
	load_decks()

func create_deck(deck: Dictionary) -> void:
	# Add or replace deck at the selected index
	if selected_deck_index >= 0 and selected_deck_index < decks.size():
		decks[selected_deck_index] = deck.duplicate()
	else:
		decks.append(deck.duplicate())
		selected_deck_index = decks.size() - 1
	save_decks()

func get_deck(index: int) -> Dictionary:
	# Return the deck at index or an empty dictionary
	return decks[index] if index >= 0 and index < decks.size() else {}

func get_selected_deck() -> Dictionary:
	return get_deck(selected_deck_index)

func set_selected_deck(index: int) -> void:
	if index >= 0 and index < decks.size():
		selected_deck_index = index

func get_deck_count() -> int:
	return decks.size()

func save_decks() -> void:
	# Persist the decks array to user://decks.json
	DataUtils.save_data("user://decks.json", decks)

func load_decks() -> void:
	# Load saved decks; DataUtils.load_data now returns Variant
	var data = DataUtils.load_data("user://decks.json")
	if data is Array:
		decks = data.duplicate()
	else:
		decks = []
		selected_deck_index = -1  # Reset selection if nothing loaded
