# res://Globals.gd (autoload)
extends Node

# Holds the currently selected deck for DeckEditor
var selected_deck: Dictionary = {}
@export var is_offline: bool = false
var current_mode: String = ""

# Added helper to detect if a deck has been set
func has_selected_deck() -> bool:
	return typeof(selected_deck) == TYPE_DICTIONARY and selected_deck.size() > 0
