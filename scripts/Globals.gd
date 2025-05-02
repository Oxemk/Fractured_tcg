extends Node

var is_offline: bool = false
var current_mode: String = ""     # “story”, “casual”, “ranked”
var vs_mode: String = ""          # “P1vsP2” or “P1vsComputer”
var p1_deck: Dictionary = {}      # Populated in VSDeckSelector
var p2_deck: Dictionary = {}
var selected_deck: Dictionary = {}# Used by DeckEditor/NewDeckPopup

func has_selected_deck() -> bool:
	return typeof(selected_deck) == TYPE_DICTIONARY and selected_deck.size() > 0
	
