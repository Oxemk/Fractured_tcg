extends Control
class_name VSDeckSelector

@onready var p1_container    := $P1Deck/P1DeckList
@onready var p2_container    := $P2Deck/P2DeckList
@onready var start_btn       := $HBoxContainer/StartButton
@onready var back_btn        := $HBoxContainer/BackButton
@onready var deck_info_label := $VBoxContainer/Label

var popup: Window

var user_decks: Array = []
var ai_decks: Array = []
var filtered_user_decks: Array = []
var filtered_ai_decks: Array = []

var random_decks = [
	{"name":"Random Easy",   "mode":"", "level":"easy",   "random":true},
	{"name":"Random Medium", "mode":"", "level":"medium", "random":true},
	{"name":"Random Hard",   "mode":"", "level":"hard",   "random":true},
]

var selected_index_p1: int = -1
var selected_index_p2: int = -1
var selecting_random_for_p1: bool = true

func _ready() -> void:
	popup = preload("res://Scenes/Battle/DifficultyPopup.tscn").instantiate()
	add_child(popup)
	popup.connect("difficulty_selected", Callable(self, "_on_difficulty_selected"))

	start_btn.connect("pressed", Callable(self, "_on_start"))
	back_btn.connect("pressed", Callable(self, "_on_back"))

	user_decks = _load_array("user://decks.json")
	ai_decks   = _load_array("res://data/decks.json")

	var mode_lc = Globals.current_mode.to_lower()
	filtered_user_decks = user_decks.filter(func(d): return d.get("mode", "").to_lower() == mode_lc)
	filtered_ai_decks   = ai_decks.filter(func(d): return d.get("mode", "").to_lower() == mode_lc)

	for entry in random_decks:
		entry["mode"] = Globals.current_mode

	_populate_buttons()
	_update_start()

func _load_array(path: String) -> Array:
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		push_warning("Failed to open '%s'" % path)
		return []
	var text = f.get_as_text()
	f.close()

	var parser = JSON.new()
	var err = parser.parse(text)
	if err != OK:
		push_warning("JSON parse error (%d) at '%s': %s" % [err, path, parser.error_string])
		return []
	var result = parser.get_data()
	if typeof(result) != TYPE_ARRAY:
		push_warning("Expected Array in JSON at '%s', got %s" % [path, typeof(result)])
		return []
	return result

func _populate_buttons() -> void:
	p1_container.clear()
	p2_container.clear()

	var all_decks = random_decks + filtered_user_decks + filtered_ai_decks
	var rng_count = random_decks.size()
	var usr_count = filtered_user_decks.size()

	for i in range(all_decks.size()):
		var d = all_decks[i]
		var prefix = ""
		if d.has("random"):
			prefix = "RNG"
		elif i < rng_count + usr_count:
			prefix = "P"
		else:
			prefix = "AI"

		var label = "[%s] %s" % [prefix, d.get("name", "Unnamed")]
		p1_container.add_item(label)
		p2_container.add_item(label)
		p1_container.set_item_metadata(p1_container.get_item_count() - 1, i)
		p2_container.set_item_metadata(p2_container.get_item_count() - 1, i)

	p1_container.connect("item_selected", Callable(self, "_on_p1_item_selected"))
	p2_container.connect("item_selected", Callable(self, "_on_p2_item_selected"))

func _on_p1_item_selected(idx: int) -> void:
	selecting_random_for_p1 = _is_random_index(idx)
	if selecting_random_for_p1:
		popup.popup_centered()
	else:
		_select_deck(idx, true)

func _on_p2_item_selected(idx: int) -> void:
	selecting_random_for_p1 = false
	if _is_random_index(idx):
		popup.popup_centered()
	else:
		_select_deck(idx, false)

func _select_deck(idx: int, is_p1: bool) -> void:
	var entry = _get_entry(idx)
	if entry.size() == 0:
		return
	var deck_copy = entry.duplicate()

	if is_p1:
		selected_index_p1 = idx
		Globals.p1_deck = deck_copy
	else:
		selected_index_p2 = idx
		Globals.p2_deck = deck_copy

	_show_deck_info(idx)
	_update_start()

func _get_entry(idx: int) -> Dictionary:
	var list = random_decks + filtered_user_decks + filtered_ai_decks
	if idx >= 0 and idx < list.size():
		return list[idx]
	return {}

func _is_random_index(idx: int) -> bool:
	return idx >= 0 and idx < random_decks.size()

func _on_difficulty_selected(level: String) -> void:
	var deck_dict = AIManager.generate_deck_dict(level, Globals.current_mode.to_lower())
	if not deck_dict.has("cards") or deck_dict.cards.empty():
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

func _show_deck_info(idx: int) -> void:
	var info: Dictionary
	if _is_random_index(idx):
		info = Globals.p1_deck if selecting_random_for_p1 else Globals.p2_deck
	else:
		info = _get_entry(idx)

	var deck_name = info.get("name", "")
	var mode  = info.get("mode", "")
	var lvl   = info.get("level", "N/A")
	var cards = info.get("cards", [])

	deck_info_label.text = "Deck Name: %s\nMode: %s\nLevel: %s\nCard Count: %d" % [deck_name, mode, lvl, cards.size()]

func _update_start() -> void:
	start_btn.disabled = (selected_index_p1 == -1) or (selected_index_p2 == -1)

func _on_start() -> void:
	if selected_index_p1 == -1 or selected_index_p2 == -1:
		return

	Globals.vs_player = true
	Globals.vs_ai = true

	get_tree().change_scene_to_file("res://Scenes/Battle/GameBoard.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
