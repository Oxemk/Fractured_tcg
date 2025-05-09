### Globals.gd
extends Node
enum VSMode { P1vsP2, P1vsComputer }

var is_offline: bool = false
var current_mode: String = ""    # "story", "casual", "ranked"
var vs_mode: int = VSMode.P1vsComputer
var p1_deck: Dictionary = {}
var p2_deck: Dictionary = {}
var selected_deck: Dictionary = {}

var card_database: Dictionary = {}

func has_selected_deck() -> bool:
	return typeof(selected_deck) == TYPE_DICTIONARY and selected_deck.size() > 0
