extends Popup
class_name CardPopup

signal add_card_to_deck(card_id: String)
signal remove_card_from_deck(card_id: String)

@onready var card_container: VBoxContainer = $CardContainer
@onready var add_button: Button = $AddButton
@onready var remove_button: Button = $RemoveButton
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var current_card_data: Dictionary = {}

func _ready() -> void:
	if not add_button or not remove_button or not anim_player:
		push_error("CardPopup: Missing required UI nodes!")
		return

	add_button.pressed.connect(_on_add_button_pressed)
	remove_button.pressed.connect(_on_remove_button_pressed)

func setup(card_data: Dictionary) -> void:
	current_card_data = card_data
	var card_image_path = card_data.get("image_path", "")
	if card_image_path == "":
		push_warning("No image path for card %s!" % card_data.get("id"))
		return
	
	# Use load() instead of preload() to handle dynamic image paths
	var card_texture = load(card_image_path)  # Using load() for dynamic paths

	if card_texture is Texture:
		var texture_rect = TextureRect.new()
		texture_rect.texture = card_texture
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card_container.clear_children()
		card_container.add_child(texture_rect)
	else:
		push_warning("Failed to load texture for card %s!" % card_data.get("id"))

	# Adjust visibility of add/remove buttons
	var card_id = card_data.get("id", "")
	var current_deck = Globals.selected_deck.get("cards", [])
	add_button.visible = card_id not in current_deck
	remove_button.visible = card_id in current_deck

func _on_add_button_pressed() -> void:
	emit_signal("add_card_to_deck", current_card_data.get("id"))
	hide()

func _on_remove_button_pressed() -> void:
	emit_signal("remove_card_from_deck", current_card_data.get("id"))
	hide()
