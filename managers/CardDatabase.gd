# CardDatabase.gd
# Autoload this script as "CardDatabase" in Project Settings > Autoload
# Place this in res://managers/CardDatabase.gd

extends Node

var cards: Dictionary = {}
func _load_card_json(id: String) -> Dictionary:
	var f = FileAccess.open("res://data/card_database.json", FileAccess.READ)
	if not f:
		push_error("Cannot open card_database.json"); return {}
	var txt = f.get_as_text(); f.close()
	var js = JSON.new()
	if js.parse(txt) != OK:
		push_error("JSON.parse error: %s" % js.error_string); return {}
	var db = js.get_data()
	for cat in db.keys():
		for c in db[cat]:
			if c.get("id", "") == id:
				return c
	return {}

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
