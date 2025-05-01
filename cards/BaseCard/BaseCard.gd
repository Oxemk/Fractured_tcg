extends Control
class_name BaseCard

@export var card_name: String        = "Unnamed"
@export var card_type: String        = "Unknown"
@export var race: String             = "none"
@export var description: String      = ""
@export var level: int               = 1
@export var image_path: String       = "res://assets/Images/placeholder.png"
@export var special_ability: String  = "None"
@export var attack_move: Dictionary  = {}
@export var cooldown: int            = 0
@export var effect: String           = "none"

var card_data: Dictionary = {}

func _ready():
	pass

func initialize_card(data: Dictionary) -> void:
	card_data = data
	# Populate from JSON
	card_name       = data.get("name", card_name)
	card_type       = data.get("card_type", card_type)
	race            = data.get("race", race)
	description     = data.get("description", description)
	level           = data.get("level", level)
	image_path      = data.get("image_path", image_path)
	special_ability = data.get("special_ability", special_ability)
	attack_move     = data.get("attack_move", attack_move)
	cooldown        = data.get("cooldown", cooldown)
	effect          = data.get("effect", effect)

	# Safe UI updates
	var name_lbl = get_node_or_null("CanvasLayer/CardName")
	if name_lbl:
		name_lbl.text = card_name
	else:
		push_error("BaseCard: 'CardName' not found!")

	var race_lbl = get_node_or_null("CanvasLayer/Race")
	if race_lbl:
		race_lbl.text = race.capitalize()
	else:
		push_error("BaseCard: 'Race' not found!")

	var img_node = get_node_or_null("CanvasLayer/CardImage")
	if img_node:
		img_node.texture = ResourceLoader.load(image_path) as Texture
	else:
		push_error("BaseCard: 'CardImage' not found!")

	var desc_lbl = get_node_or_null("CanvasLayer/description")
	if desc_lbl:
		desc_lbl.text = description
	else:
		push_error("BaseCard: 'Description' not found!")

	_set_card_color(card_type)

func _set_card_color(t: String) -> void:
	var color_map = {
		"Character": Color("#7A7C84"),
		"Weapon":    Color("#A9A9A9"),
		"Armor":     Color("#8B6F47"),
		"Support":   Color("#D4AF37"),
		"Trap":      Color("#CC5500"),
		"Field":     Color("#8F00FF")
	}
	var bg = get_node_or_null("Background")
	if bg and bg is ColorRect:
		bg.color = color_map.get(t, Color("#444444"))
	elif bg and bg is TextureRect:
		bg.modulate = color_map.get(t, Color("#444444"))
	else:
		push_error("BaseCard: 'Background' not found or unsupported!")
