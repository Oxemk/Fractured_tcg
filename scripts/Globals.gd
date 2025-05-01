extends Node

var is_offline: bool = false
var current_mode: String = ""    # “story”, “casual”, “ranked”
var vs_mode: String = ""         # “P1vsP2” or “P1vsComputer”
var p1_deck: Dictionary = {}     # Populated in VSDeckSelector
var p2_deck: Dictionary = {}


# Added helper to detect if a deck has been set
