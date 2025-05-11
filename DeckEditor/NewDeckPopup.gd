extends Popup
class_name NewDeckPopup

@export var is_edit_mode: bool = false
@export var edit_index: int = -1

# Set this before showing the popup
var parent_selector: Node = null


@onready var name_input: LineEdit       =$VBoxContainer/DeckNameInput
@onready var mode_selector: OptionButton = $VBoxContainer/mode/ModeSelector
@onready var create_button: Button      = $VBoxContainer/buttons/CreateButton
@onready var cancel_button: Button      = $VBoxContainer/buttons/CancelButton
@onready var error_label: Label         = $ErrorLabel

const MODES := {
	"Duelist":   {"rows": 1, "card_limit": 20},
	"Bodyguard": {"rows": 2, "card_limit": 30},
	"Commander": {"rows": 3, "card_limit": 40},
}

func _ready() -> void:
	# Basic checks
	if not name_input:
		push_error("DeckNameInput not found")
	if not create_button:
		push_error("CreateButton not found")
	if not cancel_button:
		push_error("CancelButton not found")
	if not error_label:
		push_error("ErrorLabel not found")

	# Connect buttons
	if create_button:
		create_button.pressed.connect(_on_create)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel)

	# Defer mode selector population
	call_deferred("_populate_mode_selector")

	# Editing mode setup
	if is_edit_mode and parent_selector:
		create_button.text = "Save"
		var decks = parent_selector.deck_data
		if edit_index >= 0 and edit_index < decks.size():
			populate_with_deck(decks[edit_index])

func _populate_mode_selector() -> void:
	if not mode_selector:
		push_error("ModeSelector not found when populating")
		return

	mode_selector.clear()
	for mode_name in MODES.keys():
		mode_selector.add_item(mode_name)

func populate_with_deck(deck_data: Dictionary) -> void:
	name_input.text = deck_data.get("name", "")
	var desired = deck_data.get("mode", "")
	for i in range(mode_selector.get_item_count()):
		if mode_selector.get_item_text(i) == desired:
			mode_selector.select(i)
			break

func _on_create() -> void:
	error_label.text = ""

	var deck_name = name_input.text.strip_edges()
	if deck_name == "":
		error_label.text = "Deck name cannot be empty."
		return

	# Prevent duplicates
	if not is_edit_mode and parent_selector:
		for d in parent_selector.deck_data:
			if d.get("name", "") == deck_name:
				error_label.text = "Deck name already in use."
				return

	var idx = mode_selector.get_selected()
	var selected = mode_selector.get_item_text(idx)
	var cfg = MODES.get(selected)
	if not cfg:
		push_error("Unknown mode: %s" % selected)
		return

	var new_deck = {
		"name":       deck_name,
		"mode":       selected,
		"card_limit": cfg.card_limit,
		"rows":       cfg.rows,
		"cards":      []
	}

	if is_edit_mode and parent_selector:
		if parent_selector.has_method("update_deck"):
			parent_selector.update_deck(edit_index, new_deck)
		else:
			parent_selector.deck_data[edit_index] = new_deck
		Globals.selected_deck = new_deck  # <-- Set selected deck for edit
		get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckEditor.tscn")  # <-- Jump to DeckEditor
	else:
		if parent_selector and parent_selector.has_method("create_deck"):
			parent_selector.create_deck(new_deck)
		elif parent_selector:
			parent_selector.deck_data.append(new_deck)
		Globals.selected_deck = new_deck
		get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckEditor.tscn")

	if parent_selector:
		if parent_selector.has_method("save_decks"):
			parent_selector.save_decks()
		if parent_selector.has_method("display_decks"):
			parent_selector.display_decks()

	queue_free()

func _on_cancel() -> void:
	queue_free()
