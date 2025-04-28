extends Node

# Import CardDatabase
const CardDatabase = preload("res://managers/CardDatabase.gd")

# Player's owned collection
var player_collection: Dictionary = {}

# When true, override and return every card
@export var unlock_all_cards: bool = false

func _ready() -> void:
	# Only load saved data if we're *not* in "all-cards" mode
	if not unlock_all_cards:
		load_collection()

func add_card(card_id: String, count: int = 1) -> void:
	# Don't bother saving when everything is unlocked
	if unlock_all_cards:
		return
	player_collection[card_id] = player_collection.get(card_id, 0) + count
	DataUtils.save_data("user://collection.json", player_collection)

func get_collection() -> Dictionary:
	if unlock_all_cards:
		# Get all cards from the CardDatabase
		return CardDatabase.get_all_cards()
	return player_collection

func load_collection() -> void:
	var data = DataUtils.load_data("user://collection.json")
	# Only assign if it's a Dictionary; otherwise start empty
	player_collection = data if data is Dictionary else {}
