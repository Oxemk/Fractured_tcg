extends Control
class_name VSDeckSelector

@onready var p1_container := $P1Deck/P1DeckList
@onready var p2_container := $P2Deck/P2DeckList
@onready var start_btn := $HBoxContainer/StartButton
@onready var back_btn := $HBoxContainer/BackButton
@onready var deck_info_label := $VBoxContainer/Label
@onready var popup := $DifficultyPopup

# Assuming AIManager is autoloaded as a singleton

var user_decks: Array = []
var ai_decks: Array = []
var filtered_user_decks: Array = []
var filtered_ai_decks: Array = []

var random_decks = [
	{ "name": "Random Easy", "mode": "", "level": "easy", "random": true },
	{ "name": "Random Medium", "mode": "", "level": "medium", "random": true },
	{ "name": "Random Hard", "mode": "", "level": "hard", "random": true },
]

var selected_index_p1: int = -1
var selected_index_p2: int = -1
var selecting_random_for_p1: bool = true

func load_data(path: String) -> Array:
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var file_data = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(file_data) == OK:
			return json.get_data()
		print("Error: JSON parsing failed")
	else:
		print("Failed to load file at %s" % path)
	return []

func _ready() -> void:
	# 1) Load & instance the popup properly
	var popup_scene = preload("res://Scenes/Battle/DifficultyPopup.tscn")
	popup = popup_scene.instantiate()
	add_child(popup)
	popup.connect("difficulty_selected", Callable(self, "_on_difficulty_selected"))

	# 2) Wire up your buttons as before
	start_btn.connect("pressed", Callable(self, "_on_start"))
	back_btn.connect("pressed", Callable(self, "_on_back"))
	_populate_buttons()

	print("VSDeckSelector _ready called")
	# ... rest of your initialization (loading decks, filtering, etc.)

	var loaded_user_decks = load_data("user://decks.json")
	var loaded_ai_decks = load_data("res://data/decks.json")
	user_decks = loaded_user_decks if loaded_user_decks is Array else []
	ai_decks = loaded_ai_decks if loaded_ai_decks is Array else []

	var mode = Globals.current_mode.to_lower()
	filtered_user_decks = user_decks.filter(func(d): return d.get("mode", "").to_lower() == mode)
	filtered_ai_decks = ai_decks.filter(func(d): return d.get("mode", "").to_lower() == mode)

	for d in random_decks:
		d["mode"] = Globals.current_mode

	start_btn.connect("pressed", Callable(self, "_on_start"))
	back_btn.connect("pressed", Callable(self, "_on_back"))
	_populate_buttons()

func _populate_buttons() -> void:
	p1_container.clear()
	p2_container.clear()

	var all_decks = random_decks + filtered_user_decks + filtered_ai_decks
	var count_rng = random_decks.size()
	var count_user = filtered_user_decks.size()

	for i in range(all_decks.size()):
		var d = all_decks[i]
		var prefix = d.has("random") and "RNG" or (i < count_rng + count_user and "P" or "AI")

		p1_container.add_item("[%s] %s" % [prefix, d.name])
		p2_container.add_item("[%s] %s" % [prefix, d.name])

		p1_container.set_item_metadata(p1_container.get_item_count() - 1, i)
		p2_container.set_item_metadata(p2_container.get_item_count() - 1, i)

	p1_container.connect("item_selected", Callable(self, "_on_p1_item_selected"))
	p2_container.connect("item_selected", Callable(self, "_on_p2_item_selected"))

func _on_p1_item_selected(index: int) -> void:
	if _is_random_index(index):
		selecting_random_for_p1 = true
		popup.popup_centered()
	else:
		_select_deck(index, true)

func _on_p2_item_selected(index: int) -> void:
	if _is_random_index(index):
		selecting_random_for_p1 = false
		popup.popup_centered()
	else:
		_select_deck(index, false)

func _select_deck(index: int, is_p1: bool) -> void:
	var deck_data = _get_deck_by_index(index)
	if deck_data.size() == 0:
		return

	var deck = deck_data[0].duplicate()
	if is_p1:
		selected_index_p1 = index
		Globals.p1_deck = deck
	else:
		selected_index_p2 = index
		Globals.p2_deck = deck

	_show_deck_info(index)
	_update_start()

func _get_deck_by_index(index: int) -> Array:
	var all_decks = random_decks + filtered_user_decks + filtered_ai_decks
	if index >= 0 and index < all_decks.size():
		return [all_decks[index]]
	return []

func _is_random_index(index: int) -> bool:
	return index >= 0 and index < random_decks.size()

func _on_difficulty_selected(level: String) -> void:
	var ai_manager = preload("res://managers/AIManager.gd").new()
	var deck_dict = ai_manager.generate_deck_dict(level, Globals.current_mode.to_lower())
	if deck_dict.cards.size() == 0:
		print("Generated random deck is empty.")
		return

	if selecting_random_for_p1:
		selected_index_p1 = 0
		Globals.p1_deck = deck_dict
		_show_deck_info(0)
	else:
		selected_index_p2 = 0
		Globals.p2_deck = deck_dict
		_show_deck_info(0)

	_update_start()

func _show_deck_info(index: int) -> void:
	var is_rand = _is_random_index(index)
	var d: Dictionary = {}
	var cards: Array = []
	var level: String = "N/A"
	var name: String = ""
	var mode: String = ""
	var rows: int = 0

	if is_rand:
		var deck = Globals.p1_deck if selecting_random_for_p1 else Globals.p2_deck

		cards = deck.cards
		level = deck.level
		name = deck.name
		mode = deck.mode
		rows = deck.rows
	else:
		d = _get_deck_by_index(index)[0]
		cards = d.cards
		level = d.get("level", "N/A")
		name = d.name
		mode = d.mode
		rows = d.rows

	deck_info_label.text = "Name: %s\nMode: %s\nLevel: %s\nSize: %d\nRows: %d" % [
		name, mode, level, cards.size(), rows
	]

func _update_start() -> void:
	start_btn.disabled = selected_index_p1 == -1 or selected_index_p2 == -1

func _on_start() -> void:
	var scene_path = "res://Scenes/Battle/GameBoard.tscn"
	if not start_btn.disabled and ResourceLoader.exists(scene_path):
		var result = get_tree().change_scene_to_file(scene_path)
		if result != OK:
			print("Failed to change scene. Error code: %d" % result)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
