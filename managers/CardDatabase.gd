extends Node

var cards: Dictionary = {}

func _ready() -> void:
	# Populate the instance cache from ALL categories in your JSON
	var raw = DataUtils.load_data("res://data/card_database.json")
	if raw is Dictionary:
		for category_name in raw.keys():
				var category_array = raw[category_name]
				if category_array is Array:
					for c in category_array:
						# Determine unique card ID: use 'id' if available, else fallback to 'name'
						var card_id: String = ""
						if c.has("id"):
							card_id = c["id"]
						elif c.has("name"):
							card_id = c["name"]
						else:
							continue
						cards[card_id] = c

static func get_all_cards() -> Dictionary:
		# Static helper: load fresh from JSON and return every card
		var db: Dictionary = {}
		var raw = DataUtils.load_data("res://data/card_database.json")
		if raw is Dictionary:
			for category_name in raw.keys():
				var category_array = raw[category_name]
				if category_array is Array:
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
