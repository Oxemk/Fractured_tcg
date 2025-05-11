extends Node
class_name sCardLoader

# Preload scenes
const CharacterScene = preload("res://cards/CharacterCard/CharCard.tscn")
const WeaponScene    = preload("res://cards/WeaponCard/WeaponCard.tscn")
const ArmorScene     = preload("res://cards/ArmorCard/ArmorCard.tscn")
const SupportScene   = preload("res://cards/SupportCard/SupportCard.tscn")
const TrapScene      = preload("res://cards/TrapCard/TrapCard.tscn")
const FieldScene     = preload("res://cards/FieldCard/FieldCard.tscn")
const ClassScene     = preload("res://cards/ClassCard/ClassCard.tscn")

static func load_card_data(data: Dictionary) -> Node:
	var scene: PackedScene
	match data.get("card_type", ""):
		"Character": scene = CharacterScene
		"Weapon":    scene = WeaponScene
		"Armor":     scene = ArmorScene
		"Support":   scene = SupportScene
		"Trap":      scene = TrapScene
		"Field":     scene = FieldScene
		"Class":     scene = ClassScene
		_: print("Unknown card type:", data.get("card_type")); return null
	var inst = scene.instantiate()
	if inst.has_method("initialize_card"):
		inst.initialize_card(data)
	return inst
