extends Popup
class_name CardPopup

signal add_card_to_deck(card_id: String)
signal remove_card_from_deck(card_id: String)

@onready var card_container: VBoxContainer = $CardContainer
@onready var add_button: Button = $AddButton
@onready var remove_button: Button = $RemoveButton

var current_card_data: Dictionary = {}
var card_scenes: Dictionary = {
	"Character": preload("res://cards/CharacterCard/Charcard.tscn"),
	"Weapon": preload("res://cards/WeaponCard/WeaponCard.tscn"),
	"Armor": preload("res://cards/ArmorCard/ArmorCard.tscn"),
	"Support": preload("res://cards/SupportCard/SupportCard.tscn"),
	"Trap": preload("res://cards/TrapCard/TrapCard.tscn"),
	"Field": preload("res://cards/FieldCard/FieldCard.tscn"),
	"Class": preload("res://cards/ClassCard/ClassCard.tscn")
}

func setup(card_data: Dictionary) -> void:
	current_card_data = card_data

	var card_type = card_data.get("type", "")
	var scene = card_scenes.get(card_type, null)
	if scene:
		var card_instance = scene.instantiate()

		if not card_container:
			push_error("CardContainer is null!")
			return

		card_container.clear_children()
		card_container.add_child(card_instance)

	var cid = card_data.get("id", "")
	var current_deck = Globals.selected_deck.get("cards", [])

	# Ensure the buttons are linked
	if not add_button or not remove_button:
		push_error("CardPopup is missing AddButton or RemoveButton!")
		return

	# Toggle visibility based on card status in the deck
	if cid in current_deck:
		add_button.visible = false
		remove_button.visible = true
	else:
		add_button.visible = true
		remove_button.visible = false

	# Connect button actions
	add_button.pressed.connect(_on_add_button_pressed)
	remove_button.pressed.connect(_on_remove_button_pressed)

	# Center the popup nicely
	popup_centered()


func _on_add_button_pressed() -> void:
	emit_signal("add_card_to_deck", current_card_data.get("id"))
	hide()

func _on_remove_button_pressed() -> void:
	emit_signal("remove_card_from_deck", current_card_data.get("id"))
	hide()
