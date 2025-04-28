extends Popup
class_name CardPopup

signal add_card_to_deck(card_id: String)
signal remove_card_from_deck(card_id: String)

@onready var card_container: VBoxContainer = get_node_or_null("CardContainer")
@onready var add_button: Button = get_node_or_null("AddButton")
@onready var remove_button: Button = get_node_or_null("RemoveButton")
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

var current_card_data: Dictionary = {}

var card_scenes: Dictionary = {
	"Character": preload("res://cards/CharacterCard/Charcard.tscn"),
	"Weapon": preload("res://cards/WeaponCard/Weaponcard.tscn"),
	"Armor": preload("res://cards/ArmorCard/ArmorCard.tscn"),
	"Support": preload("res://cards/SupportCard/SupportCard.tscn"),
	"Trap": preload("res://cards/TrapCard/TrapCard.tscn"),
	"Field": preload("res://cards/FieldCard/FieldCard.tscn"),
	"Class": preload("res://cards/ClassCard/ClassCard.tscn")
}

func _ready():
	if not card_container:
		push_error("CardPopup: 'CardContainer' node not found!")
	if not add_button:
		push_error("CardPopup: 'AddButton' node not found!")
	if not remove_button:
		push_error("CardPopup: 'RemoveButton' node not found!")
	if not anim_player:
		push_error("CardPopup: 'AnimationPlayer' node not found!")

func setup(card_data: Dictionary) -> void:
	if not card_container:
		return

	current_card_data = card_data

	var card_type = card_data.get("type", "")
	var scene = card_scenes.get(card_type)

	for child in card_container.get_children():
		child.queue_free()

	if scene:
		var card_instance = scene.instantiate()
		if card_container:
			card_container.add_child(card_instance)
		else:
			push_error("CardPopup: Cannot add card instance, card_container is null")
			return

		if card_instance.has_method("initialize_card"):
			card_instance.initialize_card(card_data)
		else:
			push_error("Card instance is missing 'initialize_card' method!")

		card_instance.mouse_filter = Control.MOUSE_FILTER_PASS
		card_instance.connect("mouse_entered", Callable(self, "_on_card_mouse_entered"))
		card_instance.connect("mouse_exited", Callable(self, "_on_card_mouse_exited"))
	else:
		push_error("No scene found for card type: %s" % card_type)

	var cid = card_data.get("id", "")
	var current_deck = Globals.selected_deck.get("cards", [])

	if add_button:
		add_button.visible = cid not in current_deck
	if remove_button:
		remove_button.visible = cid in current_deck

	if add_button:
		add_button.pressed.disconnect(Callable(self, "_on_add_button_pressed"))
		add_button.pressed.connect(Callable(self, "_on_add_button_pressed"))
	if remove_button:
		remove_button.pressed.disconnect(Callable(self, "_on_remove_button_pressed"))
		remove_button.pressed.connect(Callable(self, "_on_remove_button_pressed"))

	popup_centered()
	if anim_player:
		anim_player.play("open_popup")
	else:
		push_error("CardPopup: Cannot play animation, anim_player is null")

func _on_card_mouse_entered() -> void:
	if anim_player:
		anim_player.play("hover_grow")

func _on_card_mouse_exited() -> void:
	if anim_player:
		anim_player.play("hover_shrink")

func _on_add_button_pressed() -> void:
	emit_signal("add_card_to_deck", current_card_data.get("id"))
	hide()

func _on_remove_button_pressed() -> void:
	emit_signal("remove_card_from_deck", current_card_data.get("id"))
	hide()
