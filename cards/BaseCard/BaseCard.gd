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

# Safe value getters
func get_safe_string(dict: Dictionary, key: String, fallback: String) -> String:
	var value = dict.get(key)
	return value if typeof(value) == TYPE_STRING and value != null else fallback

func get_safe_int(dict: Dictionary, key: String, fallback: int) -> int:
	var value = dict.get(key)
	return value if typeof(value) == TYPE_INT and value != null else fallback

func get_safe_dict(dict: Dictionary, key: String, fallback: Dictionary) -> Dictionary:
	var value = dict.get(key)
	return value if typeof(value) == TYPE_DICTIONARY and value != null else fallback

# Main initializer
func initialize_card(data: Dictionary) -> void:
	card_data = data

	card_name       = get_safe_string(data, "name", card_name)
	card_type       = get_safe_string(data, "card_type", card_type)
	race            = get_safe_string(data, "race", race)
	description     = get_safe_string(data, "description", description)
	level           = get_safe_int(data, "level", level)
	image_path      = get_safe_string(data, "image_path", image_path)
	special_ability = get_safe_string(data, "special_ability", special_ability)
	attack_move     = get_safe_dict(data, "attack_move", attack_move)
	cooldown        = get_safe_int(data, "cooldown", cooldown)
	effect          = get_safe_string(data, "effect", effect)

	# Safe UI updates
	var name_lbl := get_node_or_null("CanvasLayer/CardName") as Label
	if name_lbl:
		name_lbl.text = card_name
	else:
		push_error("BaseCard: 'CardName' not found!")

	var race_lbl := get_node_or_null("CanvasLayer/Race") as Label
	if race_lbl:
		race_lbl.text = race.capitalize()
	else:
		push_error("BaseCard: 'Race' not found!")

	# --- Guarded image loading ---
	var img_node := get_node_or_null("CanvasLayer/CardImage") as TextureRect
	if img_node:
		if image_path != "" and ResourceLoader.exists(image_path, "Texture"):
			var texture = load(image_path)
			if texture is Texture2D:
				img_node.texture = texture
			else:
				push_error("BaseCard: Resource at '%s' is not a Texture2D." % image_path)
		else:
			push_warning("BaseCard: Skipping image load; invalid or missing path '%s'" % image_path)
	else:
		push_error("BaseCard: 'CardImage' not found!")

	var desc_lbl := get_node_or_null("CanvasLayer/description") as Label
	if desc_lbl:
		desc_lbl.text = description
	else:
		push_error("BaseCard: 'Description' not found!")
