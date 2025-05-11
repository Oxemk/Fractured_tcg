# CardCollectionManager.gd
# Autoload this script as "CardCollectionManager" in Project Settings > Autoload

extends Node

# When true, override and return every card from CardDatabase
@export var unlock_all_cards: bool = false

# Player's owned collection of cards
var player_collection: Dictionary = {}

func _ready() -> void:
	# Only load saved data if we're NOT in "unlock all" mode
	if not unlock_all_cards:
		load_collection()

# Add a card to the player's collection
# card_id: Unique ID for the card
# count: Number of copies to add (default is 1)
func add_card(card_id: String, count: int = 1) -> void:
	if unlock_all_cards:
		return
	
	player_collection[card_id] = player_collection.get(card_id, 0) + count
	DataUtils.save_data("user://collection.json", player_collection)

# Retrieve the player's collection
# If in "unlock all" mode, return all cards from CardDatabase
func get_collection() -> Dictionary:
	if unlock_all_cards:
		return CardDatabase.get_all_cards()
	return player_collection

# Load the player's collection from persistent storage
func load_collection() -> void:
	var data = DataUtils.load_data("user://collection.json")
	if data is Dictionary:
		player_collection = data
	else:
		player_collection = {}
