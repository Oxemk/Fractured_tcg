extends Popup
class_name NewDeckPopup

@export var is_edit_mode: bool = false
@export var edit_index: int = -1

# Will be filled in _ready()
var name_input: LineEdit
var mode_selector: OptionButton
var create_button: Button
var cancel_button: Button
var error_label: Label

# The DeckSelector (or whoever instanced us) should set this before showing:
var parent_selector: Node = null

const MODES := {
	"Duelist":   {"rows": 1, "card_limit": 20},
	"Bodyguard": {"rows": 2, "card_limit": 30},
	"Commander": {"rows": 3, "card_limit": 40},
}

func _ready() -> void:
	# Find each control by name anywhere in this popup
	name_input     = find_child("DeckNameInput") as LineEdit
	mode_selector  = find_child("ModeSelector")  as OptionButton
	create_button  = find_child("CreateButton")  as Button
	cancel_button  = find_child("CancelButton") as Button
	error_label    = find_child("ErrorLabel")    as Label

	# Sanity‐checks
	if not name_input:
		push_error("NewDeckPopup: LineEdit 'DeckNameInput' not found")
	if not mode_selector:
		push_error("NewDeckPopup: OptionButton 'ModeSelector' not found")
	if not create_button:
		push_error("NewDeckPopup: Button 'CreateButton' not found")
	if not cancel_button:
		push_error("NewDeckPopup: Button 'CancelButton' not found")
	if not error_label:
		push_error("NewDeckPopup: Label 'ErrorLabel' not found")

	# Populate the mode dropdown
	if mode_selector:
		mode_selector.clear()
		for mode_name in MODES.keys():
			mode_selector.add_item(mode_name)

	# Wire up buttons
	if create_button:
		create_button.pressed.connect(_on_create)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel)

	# If we're editing, prefill fields
	if is_edit_mode and parent_selector:
		create_button.text = "Save"
		var decks = parent_selector.deck_data
		if edit_index >= 0 and edit_index < decks.size():
			populate_with_deck(decks[edit_index])

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

	# Mode config lookup
	var idx = mode_selector.get_selected()
	var selected = mode_selector.get_item_text(idx)
	var cfg = MODES.get(selected)
	if not cfg:
		push_error("Unknown mode: %s" % selected)
		return

	# Build deck — tag with Globals.current_mode
	var new_deck = {
		"name":       deck_name,
		"mode":       Globals.current_mode,
		"card_limit": cfg.card_limit,
		"rows":       cfg.rows,
		"cards":      []
	}

	# Create or update…
	if is_edit_mode and parent_selector:
		if parent_selector.has_method("update_deck"):
			parent_selector.update_deck(edit_index, new_deck)
		else:
			parent_selector.deck_data[edit_index] = new_deck
	else:
		if parent_selector and parent_selector.has_method("create_deck"):
			parent_selector.create_deck(new_deck)
		elif parent_selector:
			parent_selector.deck_data.append(new_deck)
		Globals.selected_deck = new_deck

	# Save & refresh
	if parent_selector:
		if parent_selector.has_method("save_decks"):
			parent_selector.save_decks()
		if parent_selector.has_method("display_decks"):
			parent_selector.display_decks()

	# If new, jump into full editor
	if not is_edit_mode:
		get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckEditor.tscn")

	queue_free()

func _on_cancel() -> void:
	queue_free()
