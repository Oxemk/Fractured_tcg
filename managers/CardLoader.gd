extends Control

@export var card_data_path: String = "res://data/card_database.json"

func load_card_data(data: Dictionary) -> Node:
	var t = data.get("card_type", "")
	var inst: Node = null
	
	match t:
		"Character":
			inst = preload("res://cards/CharacterCard/Charcard.tscn").new()
		"Weapon":
			inst = preload("res://cards/WeaponCard/WeaponCard.tscn").new()
		"Armor":
			inst = preload("res://cards/ArmorCard/ArmorCard.tscn").new()
		"Support":
			inst = preload("res://cards/SupportCard/SupportCard.tscn").new()
		"Trap":
			inst = preload("res://cards/TrapCard/TrapCard.tscn").new()
		"Field":
			inst = preload("res://cards/FieldCard/FieldCard.tscn").new()
		"Class":
			inst = preload("res://cards/ClassCard/ClassCard.tscn").new()
		_:
			return null
	
	if inst:
		inst.initialize_card(data)
	return inst

func load_cards_from_json(path: String) -> Array:
	var f = FileAccess.open(path, FileAccess.READ)
	if f:
		var r = JSON.parse_string(f.get_as_text())
		f.close()
		if typeof(r) == TYPE_DICTIONARY and r.has("cards"):
			return r["cards"]
	return []
