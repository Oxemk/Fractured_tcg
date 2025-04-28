extends Popup
class_name CardPopup

signal add_card_to_deck(card_id: String)
signal remove_card_from_deck(card_id: String)

@onready var card_container: VBoxContainer = $CardContainer
@onready var add_button: Button = $AddButton
@onready var remove_button: Button = $RemoveButton
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var current_card_data: Dictionary = {}

var card_scenes: Dictionary = {
	"Character": preload("res://cards/CharacterCard/Charcard.tscn"),
	"Weapon":    preload("res://cards/WeaponCard/Weaponcard.tscn"),
	"Armor":     preload("res://cards/ArmorCard/ArmorCard.tscn"),
	"Support":   preload("res://cards/SupportCard/SupportCard.tscn"),
	"Trap":      preload("res://cards/TrapCard/TrapCard.tscn"),
	"Field":     preload("res://cards/FieldCard/FieldCard.tscn"),
	"Class":     preload("res://cards/ClassCard/ClassCard.tscn")
}

func setup(card_data: Dictionary) -> void:
	current_card_data = card_data

	var card_type = card_data.get("type", "")
	var scene = card_scenes.get(card_type)

	card_container.clear_children()

	if scene:
		var card_instance = scene.instantiate()
		card_container.add_child(card_instance)

		# Initialize visuals
		if card_instance.has_method("initialize_card"):
			card_instance.initialize_card(card_data)
		else:
			push_error("Card instance is missing 'initialize_card' method!")

		# Connect hover signals for grow effect
		card_instance.mouse_filter = Control.MOUSE_FILTER_PASS
		card_instance.connect("mouse_entered", self, "_on_card_mouse_entered")
		card_instance.connect("mouse_exited",  self, "_on_card_mouse_exited")
	else:
		push_error("No scene found for card type: " + card_type)

	# Update add/remove button visibility
	var cid = card_data.get("id", "")
	var current_deck = Globals.selected_deck.get("cards", [])

	add_button.visible    = cid not in current_deck
	remove_button.visible = cid in current_deck

	# Clean up old signal connections
	# Disconnect previous signals before connecting the new ones
	add_button.disconnect("pressed", Callable(self, "_on_add_button_pressed"))
	remove_button.disconnect("pressed", Callable(self, "_on_remove_button_pressed"))


	add_button.pressed.connect(_on_add_button_pressed)
	remove_button.pressed.connect(_on_remove_button_pressed)

	# Center and open popup with animation
	popup_centered()
	anim_player.play("open_popup")

func _on_card_mouse_entered() -> void:
	anim_player.play("hover_grow")

func _on_card_mouse_exited() -> void:
	anim_player.play("hover_shrink")

func _on_add_button_pressed() -> void:
	emit_signal("add_card_to_deck", current_card_data.get("id"))
	hide()

func _on_remove_button_pressed() -> void:
	emit_signal("remove_card_from_deck", current_card_data.get("id"))
	hide()
