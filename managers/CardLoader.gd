extends Control


@export var card_data_path: String = "res://data/card_database.json"

func load_card_data(data: Dictionary) -> Node:
	var t = data.get("card_type", "")
	var inst: Node = null
	
	match t:
		"Character":
			inst = preload("res://cards/CharacterCard/Charcard.tscn").instantiate()
		"Weapon":
			inst = preload("res://cards/WeaponCard/WeaponCard.tscn").instantiate()
		"Armor":
			inst = preload("res://cards/ArmorCard/ArmorCard.tscn").instantiate()
		"Support":
			inst = preload("res://cards/SupportCard/SupportCard.tscn").instantiate()
		"Trap":
			inst = preload("res://cards/TrapCard/TrapCard.tscn").instantiate()
		"Field":
			inst = preload("res://cards/FieldCard/FieldCard.tscn").instantiate()
		"Class":
			inst = preload("res://cards/ClassCard/ClassCard.tscn").instantiate()
		_:
			print("Unknown card type:", t)
			return null
	
	if inst and inst.has_method("initialize_card"):
		inst.initialize_card(data)
	return inst

func load_all_cards_flat(path: String) -> Dictionary:
	var flat: Dictionary = {}
	var f = FileAccess.open(path, FileAccess.READ)
	if f:
		var json = JSON.parse_string(f.get_as_text())
		f.close()
		if typeof(json) == TYPE_DICTIONARY:
			for category_name in json.keys():
				var category = json[category_name]
				if category is Array:
					for card in category:
						var card_id = card.get("id", card.get("name", ""))
						if card_id != "":
							flat[card_id] = card
	return flat
