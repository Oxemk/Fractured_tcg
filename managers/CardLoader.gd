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
			return null
	
	if inst:
		inst.initialize_card(data)  # Assuming your cards have this method to initialize them
	return inst

func load_cards_from_json(path: String) -> Array:
	var f = FileAccess.open(path, FileAccess.READ)
	if f:
		var r = JSON.parse_string(f.get_as_text())
		f.close()
		if typeof(r) == TYPE_DICTIONARY and r.has("cards"):
			return r["cards"]
	return []
