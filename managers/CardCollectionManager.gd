extends Node


# Add this line to import CardDatabase
const CardDatabase = preload("res://managers/CardDatabase.gd")

# Player's owned collection
var player_collection: Dictionary = {}


# When true, override and return every card
@export var unlock_all_cards: bool = false

func _ready() -> void:
	# Only load saved data if we're *not* in “all-cards” mode
	if not unlock_all_cards:
		load_collection()

func add_card(card_id: String, count: int = 1) -> void:
	# Don’t bother saving when everything is unlocked
	if unlock_all_cards:
		return
	player_collection[card_id] = player_collection.get(card_id, 0) + count
	DataUtils.save_data("user://collection.json", player_collection)

# In CardCollectionManager.gd
func get_collection() -> Dictionary:
	if unlock_all_cards:
		# Static call on CardDatabase now works
		return CardDatabase.get_all_cards()  # CardDatabase not imported!
	return player_collection


func load_collection() -> void:
	var data = DataUtils.load_data("user://collection.json")
	# Only assign if it’s a Dictionary; otherwise start empty
	player_collection = data if data is Dictionary else {}
static func get_all_cards() -> Dictionary:
	# Static helper: load fresh from JSON and return every card
	var db: Dictionary = {}
	var raw = DataUtils.load_data("res://data/card_database.json")
	print_debug("Raw card data loaded: ", raw != null)
	
	if raw is Dictionary:
		print_debug("Categories found: ", raw.keys())
		for category_name in raw.keys():
			var category_array = raw[category_name]
			if category_array is Array:
				print_debug("Category '%s' has %d cards" % [category_name, category_array.size()])
				for c in category_array:
					var card_id: String = ""
					if c.has("id"):
						card_id = c["id"]
					elif c.has("name"):
						card_id = c["name"]
					else:
						continue
					db[card_id] = c
	return db
