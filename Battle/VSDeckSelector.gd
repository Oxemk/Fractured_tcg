extends Control
class_name VSDeckSelector

@onready var p1_container := $VBoxContainer/PDeck/P1Deck
@onready var p2_container := $VBoxContainer/PDeck/P2Deck
@onready var start_btn := $HBoxContainer/StartButton
@onready var back_btn := $HBoxContainer/BackButton
@onready var deck_info_label := $VBoxContainer/Label
@onready var same_deck_dialog := $SameDeckDialog

var user_decks: Array = []
var ai_decks: Array = []
var filtered_user_decks: Array = []
var filtered_ai_decks: Array = []

var selected_index_p1: int = -1
var selected_index_p2: int = -1
var loaded_user_decks = DataUtils.load_data("user://decks.json")


var loaded_ai_decks = DataUtils.load_data("res://data/ai_decks.json")


func _ready() -> void:
	user_decks = loaded_user_decks if loaded_user_decks is Array else []
	ai_decks = loaded_ai_decks if loaded_ai_decks is Array else []

	filtered_user_decks = user_decks.filter(func(d): return d.mode.capitalize() == Globals.current_mode.capitalize())
	filtered_ai_decks = ai_decks.filter(func(d): return d.mode.capitalize() == Globals.current_mode.capitalize())

	_populate_buttons()

	start_btn.disabled = true
	start_btn.pressed.connect(_on_start)
	back_btn.pressed.connect(_on_back)

func _populate_buttons() -> void:
	p1_container.clear()
	p2_container.clear()

	var all_decks = filtered_user_decks + filtered_ai_decks

	for i in all_decks.size():
		var d = all_decks[i]

		var p1_btn = Button.new()
		p1_btn.text = "[%s] %s" % ["P" if i < filtered_user_decks.size() else "AI", d.name]


		p1_btn.pressed.connect(func(): _select_deck(i, true))
		p1_container.add_child(p1_btn)

		var p2_btn = Button.new()
		p2_btn.text = "[%s] %s" % ["P" if i < filtered_user_decks.size() else "AI", d.name]
		p2_btn.pressed.connect(func(): _select_deck(i, false))
		p2_container.add_child(p2_btn)

func _select_deck(index: int, is_p1: bool) -> void:
	if is_p1:
		selected_index_p1 = index
	else:
		selected_index_p2 = index

	_show_deck_info(index)
	_update_start()

func _get_deck_by_index(idx: int) -> Dictionary:
	return filtered_user_decks[idx] if idx < filtered_user_decks.size() else filtered_ai_decks[idx - filtered_user_decks.size()]

func _show_deck_info(index: int) -> void:
	var deck = _get_deck_by_index(index)
	var name = deck.get("name", "Unknown")
	var mode = deck.get("mode", "Unknown")
	var level = str(deck.get("level", "?"))
	var size = deck.get("cards", []).size()

	deck_info_label.text = "Name: %s\nMode: %s\nLevel: %s\nSize: %d" % [name, mode, level, size]

func _update_start() -> void:
	var valid = selected_index_p1 != -1 and selected_index_p2 != -1 and selected_index_p1 != selected_index_p2
	start_btn.disabled = not valid

func _on_start() -> void:
	var deck1 = _get_deck_by_index(selected_index_p1)
	var deck2 = _get_deck_by_index(selected_index_p2)

	if Globals.vs_mode != "P1vsP2" and deck1.name == deck2.name:
		same_deck_dialog.popup_centered()
		same_deck_dialog.confirmed.connect_once(func():
			Globals.p1_deck = deck1.duplicate()
			Globals.p2_deck = deck2.duplicate()
			get_tree().change_scene_to_file("res://Scenes/Battle/GameBoard.tscn")
		)
	else:
		Globals.p1_deck = deck1.duplicate()
		Globals.p2_deck = deck2.duplicate()
		get_tree().change_scene_to_file("res://Scenes/Battle/GameBoard.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
