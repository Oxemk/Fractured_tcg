# CardDatabase.gd
# Autoload this script as "CardDatabase" in Project Settings > Autoload
# Place this in res://managers/CardDatabase.gd

extends Node

var cards: Dictionary = {}

func _ready() -> void:
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
						print("Warning: Card missing 'id' or 'name', skipping:", c)
						continue
					cards[card_id] = c
			else:
				print("Warning: Invalid format for category: %s" % category_name)
	else:
		push_error("CardDatabase: Failed to load card data or format invalid.")

func get_all_cards() -> Dictionary:
	return cards
