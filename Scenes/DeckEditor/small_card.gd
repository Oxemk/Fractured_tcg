
# smallcard.gd
# Place this in res://Scenes/DeckEditor/SmallCard.tscn
extends Panel
class_name SmallCard

signal clicked(card_id: String)

@onready var card_container: Control = get_node_or_null("CardContainer")

var card_id: String = ""
var card_data: Dictionary = {}

var card_scenes = {
	"Character": preload("res://cards/CharacterCard/Charcard.tscn"),
	"Weapon":    preload("res://cards/WeaponCard/WeaponCard.tscn"),
	"Armor":     preload("res://cards/ArmorCard/ArmorCard.tscn"),
	"Support":   preload("res://cards/SupportCard/SupportCard.tscn"),
	"Trap":      preload("res://cards/TrapCard/TrapCard.tscn"),
	"Field":     preload("res://cards/FieldCard/FieldCard.tscn"),
	"Class":     preload("res://cards/ClassCard/ClassCard.tscn")
}

func _ready() -> void:
	# Ensure the panel is visible
	custom_minimum_size = Vector2(128, 192)

func setup(id: String, data: Dictionary) -> void:
	card_id = id
	card_data = data

	if not card_container:
		push_error("SmallCard: 'CardContainer' node missing in scene.")
		return

	# Clear old content
	for child in card_container.get_children(): child.queue_free()

	var scene = card_scenes.get(data.get("card_type", ""))
	if not scene:
		push_error("SmallCard: No scene for type '%s'" % data.get("card_type"))
		return

	var inst = scene.instantiate()
	# Stretch to container
	if inst is Control:
		inst.anchor_left = 0; inst.anchor_top = 0; inst.anchor_right = 1; inst.anchor_bottom = 1
		inst.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inst.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_container.add_child(inst)

	if inst.has_method("initialize_card"):
		inst.initialize_card(data)
	else:
		push_error("SmallCard: Scene lacks initialize_card() for ID '%s'" % id)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", card_id)
