extends Panel

var card_name: Label
var card_type: Label
var card_effect: Label

func _ready():
	card_name = $CardName
	card_type = $CardType
	card_effect = $CardEffect

func set_card_data(data: Dictionary):
	card_name.text = data["name"]
	card_type.text = data["type"]
	card_effect.text = data["effect"]
