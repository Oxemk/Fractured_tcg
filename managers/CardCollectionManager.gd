extends Node

# Import CardDatabase (preload is used to load the script for efficiency)
const CardDatabase = preload("res://managers/CardDatabase.gd")

# Player's owned collection of cards
var player_collection: Dictionary = {}

# When true, override and return every card from the CardDatabase
@export var unlock_all_cards: bool = false

func _ready() -> void:
	# Only load saved data if we're *not* in "all-cards" mode
	if not unlock_all_cards:
		load_collection()

# Add a card to the player's collection
# card_id: Unique ID for the card
# count: Number of copies to add (default is 1)
func add_card(card_id: String, count: int = 1) -> void:
	# If all cards are unlocked, don't bother adding any specific cards
	if unlock_all_cards:
		return
	
	# Add the card to the collection
	player_collection[card_id] = player_collection.get(card_id, 0) + count
	
	# Save the collection to disk after modifying it
	DataUtils.save_data("user://collection.json", player_collection)

# Retrieve the player's collection
# If in "unlock all" mode, return all cards from the CardDatabase
func get_collection() -> Dictionary:
	if unlock_all_cards:
		# Get all cards from the CardDatabase
		return CardDatabase.get_all_cards()
	
	# Return the player's personal collection
	return player_collection

# Load the player's collection from persistent storage
func load_collection() -> void:
	# Try loading the collection from the saved file
	var data = DataUtils.load_data("user://collection.json")
	
	# Only assign to player_collection if the loaded data is a Dictionary
	# Otherwise, start with an empty collection
	if data is Dictionary:
		player_collection = data
	else:
		player_collection = {}
