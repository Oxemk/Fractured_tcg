extends Popup
class_name CardPopup

signal add_card_to_deck(card_id: String)
signal remove_card_from_deck(card_id: String)

@onready var card_container = $CardContainer
@onready var add_button     = $AddButton
@onready var remove_button  = $RemoveButton
@onready var anim_player    = $AnimationPlayer

var current_card_data: Dictionary = {}
var card_scenes: Dictionary = {
	"Character": preload("res://cards/CharacterCard/Charcard.tscn"),
	"Weapon":    preload("res://cards/WeaponCard/Weaponcard.tscn"),
##and the others

}

func setup(data: Dictionary) -> void:
	if not card_container or not data:
		return
	current_card_data = data
	var t = data.get("card_type", "")
	var scene = card_scenes.get(t)
	if not scene:
		push_error("CardPopup: no scene for %s" % t)
		return

	# clear previous
	for c in card_container.get_children():
		c.queue_free()

	# instance & init
	var inst = scene.instantiate()
	card_container.add_child(inst)
	if inst.has_method("initialize_card"):
		inst.initialize_card(data)
	inst.mouse_filter = Control.MOUSE_FILTER_PASS

	# configure buttons
	var cid = data.get("id", "")
	add_button.visible    = cid != "" and cid not in Globals.selected_deck.cards
	remove_button.visible = cid != "" and cid in Globals.selected_deck.cards

	# safe connections
	if not add_button.is_connected("pressed", Callable(self, "_on_add_button_pressed")):
		add_button.pressed.connect(Callable(self, "_on_add_button_pressed"))
	if not remove_button.is_connected("pressed", Callable(self, "_on_remove_button_pressed")):
		remove_button.pressed.connect(Callable(self, "_on_remove_button_pressed"))

	popup_centered()
	anim_player.play("open_popup")

func _on_add_button_pressed() -> void:
	emit_signal("add_card_to_deck", current_card_data.id)
	hide()

func _on_remove_button_pressed() -> void:
	emit_signal("remove_card_from_deck", current_card_data.id)
	hide()
