extends Control
class_name BaseCard

@export var card_name: String = "Unnamed"
@export var card_type: String = "Unknown"
@export var level: int = 1
@export var image_path: String = "res://assets/Images/placeholder.png"
@export var special_ability: String = "None"
@export var attack_move: Dictionary = {}
@export var cooldown: int = 0
@export var effect: Dictionary = {}

func _ready(): 
	pass

var card_data: Dictionary

func initialize_card(data: Dictionary) -> void:
	card_data = data
	# Optional: Update visuals using data values here
	card_name = data.get("name", "Unnamed")
	card_type = data.get("card_type", "Unknown")
	level = data.get("level", 1)
	image_path = data.get("image_path", "res://assets/Images/placeholder.png")
	special_ability = data.get("special_ability", "None")
	attack_move = data.get("attack_move", {})
	cooldown = data.get("cooldown", 0)
	effect = data.get("effect", {})
	
	$CardName.text = card_name
	$CardImage.texture = load(image_path)
	_set_card_color(card_type)

func _set_card_color(t: String) -> void:
	var c: Color = Color("#444444") # Default color
	match t:
		"Character":
			c = Color("#7A7C84")
		"Weapon":
			c = Color("#A9A9A9")
		"Armor":
			c = Color("#8B6F47")
		"Support":
			c = Color("#D4AF37")
		"Trap":
			c = Color("#CC5500")
		"Field":
			c = Color("#8F00FF")
	
	$Background.color = c
