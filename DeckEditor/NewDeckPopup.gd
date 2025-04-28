extends Popup
class_name NewDeckPopup

@export var is_edit_mode: bool = false
@export var edit_index: int = -1

@onready var name_input: LineEdit        = $VBoxContainer/DeckNameInput
@onready var mode_selector: OptionButton = get_node_or_null("VBoxContainer/mode/ModeSelector")
@onready var create_button: Button       = $VBoxContainer/buttons/CreateButton
@onready var cancel_button: Button       = $VBoxContainer/buttons/CancelButton
@onready var error_label: Label          = $ErrorLabel

var parent_selector: Node = null

const MODES: Dictionary = {
	"Duelist":   {"rows": 1, "card_limit": 20},
	"Bodyguard": {"rows": 2, "card_limit": 30},
	"Commander": {"rows": 3, "card_limit": 40}
}

func _ready() -> void:
	if not name_input:
		push_error("NewDeckPopup: LineEdit not found.")
	if not mode_selector:
		push_error("NewDeckPopup: OptionButton not found.")
	if not create_button:
		push_error("NewDeckPopup: CreateButton not found.")
	if not cancel_button:
		push_error("NewDeckPopup: CancelButton not found.")
	if not error_label:
		push_error("NewDeckPopup: ErrorLabel not found.")

	if mode_selector:
		mode_selector.clear()
		for mode_name in MODES.keys():
			mode_selector.add_item(mode_name)

	if create_button:
		create_button.pressed.connect(_on_create)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel)

	if is_edit_mode and create_button:
		create_button.text = "Save"

func populate_with_deck(deck_data: Dictionary) -> void:
	name_input.text = deck_data.get("name", "")
	var desired_mode = deck_data.get("mode", "")
	if mode_selector:
		for i in range(mode_selector.get_item_count()):
			if mode_selector.get_item_text(i) == desired_mode:
				mode_selector.select(i)
				break
	if create_button:
		create_button.text = "Save"

func _on_create() -> void:
	var deck_name := name_input.text.strip_edges()
	if deck_name == "":
		error_label.text = "Deck name cannot be empty."
		return
	
	# Check if name exists (only for new decks)
	if not is_edit_mode:
		var name_exists = false
		for deck in parent_selector.deck_data:
			if deck.get("name", "") == deck_name:
				name_exists = true
				break
				
		if name_exists:
			error_label.text = "Deck name already in use."
			return
			
	var selected_mode := mode_selector and mode_selector.get_item_text(mode_selector.selected) or ""
	var cfg = MODES.get(selected_mode, {})
	var new_deck = {
		"name":       deck_name,
		"mode":       selected_mode,
		"card_limit": cfg.get("card_limit", 0),
		"rows":       cfg.get("rows", 0),
		"cards":      []
	}
	if is_edit_mode:
		if parent_selector.has_method("update_deck"):
			parent_selector.update_deck(edit_index, new_deck)
		else:
			parent_selector.deck_data[edit_index] = new_deck
	else:
		if parent_selector.has_method("create_deck"):
			parent_selector.create_deck(new_deck)
		else:
			parent_selector.deck_data.append(new_deck)
	if parent_selector.has_method("save_decks"):
		parent_selector.save_decks()
	if parent_selector.has_method("display_decks"):
		parent_selector.display_decks()
	
	# If this was a new deck, set the selected deck and go to the editor
	if not is_edit_mode:
		# Set the global selected deck
		Globals.selected_deck = new_deck
		get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckEditor.tscn")
	queue_free()

func _on_cancel() -> void:
	queue_free()
