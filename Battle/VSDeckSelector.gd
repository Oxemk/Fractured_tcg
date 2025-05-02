extends Control
class_name VSDeckSelector

@onready var p1_container := $P1Deck/P1DeckList
@onready var p2_container := $P1Deck2/P1DeckList
@onready var start_btn := $HBoxContainer/StartButton
@onready var back_btn := $HBoxContainer/BackButton
@onready var deck_info_label := $VBoxContainer/Label
@onready var same_deck_dialog := $SameDeckDialog

var user_decks: Array = []
var ai_decks: Array = []
var filtered_user_decks: Array = []
var filtered_ai_decks: Array = []

var p1_buttons: Array = []
var p2_buttons: Array = []

var selected_index_p1: int = -1
var selected_index_p2: int = -1

func _ready() -> void:
	var lu = DataUtils.load_data("user://decks.json")
	user_decks = lu.decks if typeof(lu) == TYPE_DICTIONARY and lu.has("decks") and lu.decks is Array else []

	var la = DataUtils.load_data("res://data/decks.json")
	ai_decks = la.decks if typeof(la) == TYPE_DICTIONARY and la.has("decks") and la.decks is Array else []

	filtered_user_decks = user_decks.filter(func(d): return d.mode.capitalize() == Globals.current_mode.capitalize())
	filtered_ai_decks = ai_decks.filter(func(d): return d.mode.capitalize() == Globals.current_mode.capitalize())

	_populate_buttons()

	start_btn.pressed.connect(_on_start)
	start_btn.disabled = true
	back_btn.pressed.connect(_on_back)

func _populate_buttons() -> void:
	p1_container.clear()
	p2_container.clear()
	p1_buttons.clear()
	p2_buttons.clear()

	var all_decks = filtered_user_decks + filtered_ai_decks

	for i in range(all_decks.size()):
		var deck = all_decks[i]
		var prefix = "P" if i < filtered_user_decks.size() else "AI"

		# Create button for P1
		var b1 = Button.new()
		b1.text = "[%s] %s" % [prefix, deck.name]
		b1.pressed.connect(func(): _select_deck(i, true))
		p1_container.add_child(b1)
		p1_buttons.append(b1)

		# Create button for P2
		var b2 = Button.new()
		b2.text = "[%s] %s" % [prefix, deck.name]
		b2.pressed.connect(func(): _select_deck(i, false))
		p2_container.add_child(b2)
		p2_buttons.append(b2)

func _select_deck(index: int, is_p1: bool) -> void:
	if is_p1:
		selected_index_p1 = index
	else:
		selected_index_p2 = index

	_show_deck_info(index)
	_update_button_highlight()
	_update_start()

func _get_deck_by_index(idx: int) -> Dictionary:
	if idx < filtered_user_decks.size():
		return filtered_user_decks[idx]
	var ai_index := idx - filtered_user_decks.size()
	if ai_index < filtered_ai_decks.size():
		return filtered_ai_decks[ai_index]
	return {}

func _show_deck_info(index: int) -> void:
	var d = _get_deck_by_index(index)
	deck_info_label.text = "Name: %s\nMode: %s\nLevel: %s\nSize: %d" % [
		d.get("name", "Unknown"),
		d.get("mode", "Unknown"),
		str(d.get("level", "?")),
		d.get("cards", []).size()
	]

func _update_start() -> void:
	start_btn.disabled = selected_index_p1 < 0 or selected_index_p2 < 0

func _update_button_highlight() -> void:
	# Reset all button styles
	for i in range(p1_buttons.size()):
		p1_buttons[i].remove_theme_color_override("font_color")
		p1_buttons[i].remove_theme_color_override("bg_color")
	for i in range(p2_buttons.size()):
		p2_buttons[i].remove_theme_color_override("font_color")
		p2_buttons[i].remove_theme_color_override("bg_color")

	# Highlight selections
	if selected_index_p1 >= 0 and selected_index_p1 < p1_buttons.size():
		p1_buttons[selected_index_p1].add_theme_color_override("font_color", Color.BLACK)
		p1_buttons[selected_index_p1].add_theme_color_override("bg_color", Color.YELLOW)

	if selected_index_p2 >= 0 and selected_index_p2 < p2_buttons.size():
		p2_buttons[selected_index_p2].add_theme_color_override("font_color", Color.BLACK)
		p2_buttons[selected_index_p2].add_theme_color_override("bg_color", Color.YELLOW)

func _on_start() -> void:
	if selected_index_p1 < 0 or selected_index_p2 < 0:
		return

	var d1 = _get_deck_by_index(selected_index_p1)
	var d2 = _get_deck_by_index(selected_index_p2)

	if Globals.vs_mode != "P1vsP2" and d1.name == d2.name:
		same_deck_dialog.popup_centered()
		same_deck_dialog.confirmed.connect_once(func():
			Globals.p1_deck = d1.duplicate()
			Globals.p2_deck = d2.duplicate()
			get_tree().change_scene_to_file("res://Scenes/Battle/GameBoard.tscn")
		)
	else:
		Globals.p1_deck = d1.duplicate()
		Globals.p2_deck = d2.duplicate()
		get_tree().change_scene_to_file("res://Scenes/Battle/GameBoard.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
