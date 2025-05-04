extends Control
class_name VSDeckSelector

@onready var p1_container := $P1Deck/P1DeckList
@onready var p2_container := $P2Deck/P2DeckList
@onready var start_btn := $HBoxContainer/StartButton
@onready var back_btn := $HBoxContainer/BackButton
@onready var deck_info_label := $VBoxContainer/Label
@onready var same_deck_dialog := $SameDeckDialog

@onready var AI = get_node("/root/AIManager")

var user_decks: Array = []
var ai_decks: Array = []
var filtered_user_decks: Array = []
var filtered_ai_decks: Array = []

var selected_index_p1: int = -1
var selected_index_p2: int = -1

var loaded_user_decks = load_data("user://decks.json")
var loaded_ai_decks = load_data("res://data/decks.json")

var random_decks = [
	{ "name": "Random Easy", "mode": "", "level": "easy", "random": true },
	{ "name": "Random Medium", "mode": "", "level": "medium", "random": true },
	{ "name": "Random Hard", "mode": "", "level": "hard", "random": true },
]

func _ready() -> void:
	user_decks = loaded_user_decks if loaded_user_decks is Array else []
	ai_decks = loaded_ai_decks if loaded_ai_decks is Array else []

	print("Current mode: ", Globals.current_mode)
	print("Loaded user decks: ", user_decks)
	print("Loaded AI decks: ", ai_decks)

	# Ensure mode is properly handled in lowercase
	var mode = Globals.current_mode.to_lower()
	filtered_user_decks = user_decks.filter(func(d): return d["mode"].to_lower() == mode)
	filtered_ai_decks = ai_decks.filter(func(d): return d["mode"].to_lower() == mode)

	print("Filtered user decks: ", filtered_user_decks)
	print("Filtered AI decks: ", filtered_ai_decks)

	# Set the mode for random decks to match the current mode
	for d in random_decks:
		d["mode"] = Globals.current_mode

	_populate_buttons()
	start_btn.disabled = true
	start_btn.connect("pressed", Callable(self, "_on_start"))
	back_btn.connect("pressed", Callable(self, "_on_back"))

func _populate_buttons() -> void:
	# Clear the existing items in the containers
	p1_container.clear()
	p2_container.clear()

	var all_decks = random_decks + filtered_user_decks + filtered_ai_decks
	var count_rng = random_decks.size()
	var count_user = filtered_user_decks.size()

	print("All combined decks: ", all_decks)

	# Add decks to buttons
	for i in range(all_decks.size()):
		var d = all_decks[i]
		var prefix = "RNG" if d.has("random") else ("P" if i < count_rng + count_user else "AI")

		p1_container.add_item("[%s] %s" % [prefix, d.name])
		p2_container.add_item("[%s] %s" % [prefix, d.name])

		p1_container.set_item_metadata(p1_container.get_item_count() - 1, i)
		p2_container.set_item_metadata(p2_container.get_item_count() - 1, i)

	p1_container.connect("item_selected", Callable(self, "_on_p1_item_selected"))
	p2_container.connect("item_selected", Callable(self, "_on_p2_item_selected"))

	print("Buttons populated")

func _on_p1_item_selected(index: int) -> void:
	_select_deck(index, true)

func _on_p2_item_selected(index: int) -> void:
	_select_deck(index, false)

func _select_deck(index: int, is_p1: bool) -> void:
	var decks = _get_deck_by_index(index)
	if decks.size() == 0:
		print("Error: No deck found at index %d" % index)
		return

	var deck = decks[0].duplicate()

	if is_p1:
		selected_index_p1 = index
		Globals.p1_deck = deck
	else:
		selected_index_p2 = index
		Globals.p2_deck = deck

	_show_deck_info(index)
	_update_start()
	_update_button_highlight()

func _get_deck_by_index(idx: int) -> Array:
	var all_decks = random_decks + filtered_user_decks + filtered_ai_decks

	if all_decks.size() == 0 or idx < 0 or idx >= all_decks.size():
		print("Error: Invalid deck index %d" % idx)
		return []

	var deck = all_decks[idx]

	if deck.has("random"):
		if AI == null:
			print("Error: AI node is null!")
			return []
		if not deck.has("level"):
			print("Warning: Missing 'level' in random deck:", deck.name)
			deck["level"] = "default"

		return [{
			"name": deck.name,
			"mode": deck.mode,
			"level": deck.level,
			"cards": AI.get_deck(deck.level, deck.mode)
		}]
	return [deck]

func _show_deck_info(index: int) -> void:
	var d = _get_deck_by_index(index)[0]
	deck_info_label.text = "Name: %s\nMode: %s\nLevel: %s\nSize: %d" % [
		d.name, d.mode, d.get("level", "N/A"), str(d.cards.size())
	]

func _update_start() -> void:
	var both_selected = (selected_index_p1 != -1 and selected_index_p2 != -1)
	var not_same = (selected_index_p1 != selected_index_p2)

	if both_selected:
		if not_same:
			start_btn.disabled = false
		else:
			start_btn.disabled = true
			same_deck_dialog.popup_centered()
	else:
		start_btn.disabled = true

func _update_button_highlight() -> void:
	pass

func _on_start() -> void:
	print("Start button pressed")

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
	print("Going back to main menu...")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func load_data(path: String) -> Array:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var content = file.get_as_text()
		print("Loaded file content: ", content)

		var json_parser = JSON.new()
		var result = json_parser.parse(content)
		if result == OK:
			var data = json_parser.get_data()
			return data if data is Array else []
		else:
			print("Failed to parse JSON.")
	else:
		print("File does not exist: ", path)
	return []
