extends Control
class_name VSDeckSelector

@onready var p1_container := $P1Deck/P1DeckList
@onready var p2_container := $P2Deck/P2DeckList
@onready var start_btn := $HBoxContainer/StartButton
@onready var back_btn := $HBoxContainer/BackButton
@onready var deck_info_label := $VBoxContainer/Label
@onready var same_deck_dialog := $SameDeckDialog

@onready var AI = get_node("res://managers/AIManager.gd")

var user_decks: Array = []
var ai_decks: Array = []
var filtered_user_decks: Array = []
var filtered_ai_decks: Array = []

var random_decks = [
	{ "name": "Random Easy", "mode": "", "level": "easy", "random": true },
	{ "name": "Random Medium", "mode": "", "level": "medium", "random": true },
	{ "name": "Random Hard", "mode": "", "level": "hard", "random": true },
]

var card_database = {
	"char_trollkin_001": {"name": "Trollkin", "type": "character", "attack": 5, "health": 10},
	"carmor_001": {"name": "Carmore Armor", "type": "armor", "defense": 3}
	# Add more card definitions as needed
}

var selected_index_p1: int = -1
var selected_index_p2: int = -1

func _ready() -> void:
	print("VSDeckSelector _ready called")
	
	# Load user and AI decks
	var loaded_user_decks = load_data("user://decks.json")
	var loaded_ai_decks = load_data("res://data/decks.json")
	user_decks = loaded_user_decks if loaded_user_decks is Array else []
	ai_decks = loaded_ai_decks if loaded_ai_decks is Array else []
	print("Loaded user decks: %d, Loaded AI decks: %d" % [user_decks.size(), ai_decks.size()])

	# Filter decks based on current mode
	var mode = Globals.current_mode.to_lower()
	print("Filtering decks for mode: %s" % mode)
	filtered_user_decks = user_decks.filter(func(d): return d["mode"].to_lower() == mode)
	filtered_ai_decks = ai_decks.filter(func(d): return d["mode"].to_lower() == mode)
	print("Filtered user decks: %d, Filtered AI decks: %d" % [filtered_user_decks.size(), filtered_ai_decks.size()])

	# Set the mode for random decks to match the current mode
	for d in random_decks:
		d["mode"] = Globals.current_mode
	print("Random decks updated to mode: %s" % Globals.current_mode)

	_populate_buttons()
	start_btn.disabled = true
	start_btn.connect("pressed", Callable(self, "_on_start"))
	back_btn.connect("pressed", Callable(self, "_on_back"))

func _populate_buttons() -> void:
	print("_populate_buttons called")
	
	# Clear the existing items in the containers
	p1_container.clear()
	p2_container.clear()

	var all_decks = random_decks + filtered_user_decks + filtered_ai_decks
	var count_rng = random_decks.size()
	var count_user = filtered_user_decks.size()
	print("Total decks to display: %d (Random: %d, User: %d, AI: %d)" % [all_decks.size(), count_rng, count_user, filtered_ai_decks.size()])

	# Add decks to buttons
	for i in range(all_decks.size()):
		var d = all_decks[i]
		var prefix = "RNG" if d.has("random") else ("P" if i < count_rng + count_user else "AI")
		print("Adding deck to button: %s [%s] %s" % [prefix, d.name, d.mode])

		p1_container.add_item("[%s] %s" % [prefix, d.name])
		p2_container.add_item("[%s] %s" % [prefix, d.name])

		p1_container.set_item_metadata(p1_container.get_item_count() - 1, i)
		p2_container.set_item_metadata(p2_container.get_item_count() - 1, i)

	p1_container.connect("item_selected", Callable(self, "_on_p1_item_selected"))
	p2_container.connect("item_selected", Callable(self, "_on_p2_item_selected"))

func _on_p1_item_selected(index: int) -> void:
	print("_on_p1_item_selected called with index: %d" % index)
	_select_deck(index, true)

func _on_p2_item_selected(index: int) -> void:
	print("_on_p2_item_selected called with index: %d" % index)
	_select_deck(index, false)

func _select_deck(index: int, is_p1: bool) -> void:
	print("_select_deck called with index: %d, is_p1: %s" % [index, str(is_p1)])
	var decks = _get_deck_by_index(index)
	if decks.size() == 0:
		print("Error: No deck found at index %d" % index)
		return

	var deck = decks[0].duplicate()

	if is_p1:
		selected_index_p1 = index
		Globals.p1_deck = deck
		print("Player 1 selected deck at index %d" % index)
	else:
		selected_index_p2 = index
		Globals.p2_deck = deck
		print("Player 2 selected deck at index %d" % index)

	_show_deck_info(index)
	_update_start()

func _get_deck_by_index(index: int) -> Array:
	print("_get_deck_by_index called with index: %d" % index)
	var all_decks = random_decks + filtered_user_decks + filtered_ai_decks
	if index >= 0 and index < all_decks.size():
		print("Deck found at index %d" % index)
		return [all_decks[index]]  # Return the deck at the given index in an array
	print("No deck found at index %d" % index)
	return []  # Return an empty array if the index is out of bounds

func _show_deck_info(index: int) -> void:
	print("_show_deck_info called for index: %d" % index)
	var d = _get_deck_by_index(index)[0]
	deck_info_label.text = "Name: %s\nMode: %s\nLevel: %s\nSize: %d\nRows: %d" % [
		d.name, d.mode, (d.has("level") if d.has("level") else "N/A"), str(d.cards.size()), d.rows
	]
	print("Deck info: Name: %s, Mode: %s, Level: %s, Size: %d, Rows: %d" % [
		d.name, d.mode, (d.has("level") if d.has("level") else "N/A"), d.cards.size(), d.rows
	])

func _update_start() -> void:
	print("_update_start called")
	var both_selected = (selected_index_p1 != -1 and selected_index_p2 != -1)
	var not_same = (selected_index_p1 != selected_index_p2)

	if both_selected:
		if not_same:
			start_btn.disabled = false
			print("Start button enabled")
		else:
			start_btn.disabled = true
			same_deck_dialog.popup_centered()
			print("Start button disabled (same deck selected)")
	else:
		start_btn.disabled = true
		print("Start button disabled (no deck selected)")

func _on_start() -> void:
	print("_on_start called")
	
	var scene_path := "res://Scenes/Battle/GameBoard.tscn"

	if not start_btn.disabled:
		if ResourceLoader.exists(scene_path):
			print("Scene found. Changing to:", scene_path)

			var result := get_tree().change_scene_to_file(scene_path)
			if result != OK:
				print("Failed to change scene. Error code:", result)
			else:
				print("Scene change successful.")
		else:
			print("Scene NOT FOUND at path:", scene_path)
	else:
		print("Start button is disabled. Scene change blocked.")

func _on_back() -> void:
	print("_on_back called")
	print("Going back to main menu...")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func load_data(path: String) -> Array:
	print("load_data called with path: %s" % path)
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var content = file.get_as_text()

		var json_parser = JSON.new()
		var result = json_parser.parse(content)
		if result == OK:
			var data = json_parser.get_data()
			print("Data loaded successfully from %s" % path)
			return data if data is Array else []
		else:
			print("Failed to parse JSON from %s" % path)
	else:
		print("File does not exist: ", path)
	return []
