extends Popup
class_name CardPopup

signal add_card_to_deck(card_id: String)
signal remove_card_from_deck(card_id: String)

@onready var card_container = $CardContainer
@onready var add_button     = $AddButton
@onready var remove_button  = $RemoveButton
@onready var anim_player    = $AnimationPlayer

var current_card_id: String = ""
var current_card_data: Dictionary = {}
var card_scenes = {
	"Character": preload("res://cards/CharacterCard/Charcard.tscn"),
	"Weapon":    preload("res://cards/WeaponCard/WeaponCard.tscn"),
	"Armor":     preload("res://cards/ArmorCard/ArmorCard.tscn"),
	"Support":   preload("res://cards/SupportCard/SupportCard.tscn"),
	"Trap":      preload("res://cards/TrapCard/TrapCard.tscn"),
	"Field":     preload("res://cards/FieldCard/FieldCard.tscn"),
	"Class":     preload("res://cards/ClassCard/ClassCard.tscn")
}

func setup(card_id: String, data: Dictionary) -> void:
	current_card_id = card_id
	current_card_data = data

	# Clear old
	for c in card_container.get_children():
		c.queue_free()

	var scene = card_scenes.get(data.get("card_type", ""))
	if not scene:
		push_error("CardPopup: no scene for type '%s'" % data.get("card_type"))
		return

	var inst = scene.instantiate()
	card_container.add_child(inst)
	if inst.has_method("initialize_card"):
		inst.initialize_card(data)

	# Buttons
	add_button.visible    = not (card_id in Globals.selected_deck.cards)
	remove_button.visible = (card_id in Globals.selected_deck.cards)

	# Connect using Godot 4.x syntax
	if not add_button.pressed.is_connected(_on_add_pressed):
		add_button.pressed.connect(_on_add_pressed)
	if not remove_button.pressed.is_connected(_on_remove_pressed):
		remove_button.pressed.connect(_on_remove_pressed)

	popup_centered()
	anim_player.play("open_popup")

func _on_add_pressed() -> void:
	emit_signal("add_card_to_deck", current_card_id)
	hide()

func _on_remove_pressed() -> void:
	emit_signal("remove_card_from_deck", current_card_id)
	hide()
