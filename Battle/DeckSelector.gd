extends Control
class_name DeckSelector

const MAX_DECKS = 10
const NEW_DECK_POPUP_PATH := "res://Scenes/DeckEditor/NewDeckPopup.tscn"

@onready var deck_list: ItemList = $VBoxContainer/DeckList2
@onready var new_deck_button: Button = $VBoxContainer/HBoxContainer/NewDeckButton
@onready var edit_button: Button = $VBoxContainer/HBoxContainer/Edit
@onready var delete_button: Button = $VBoxContainer/HBoxContainer/Delete
@onready var back: Button = $VBoxContainer/HBoxContainer/back

var deck_data: Array = []
var selected_index := -1

func _ready():
	load_decks()
	display_decks()
	_check_button_states()
	new_deck_button.pressed.connect(_on_new_deck)
	edit_button.pressed.connect(_on_edit_deck)
	delete_button.pressed.connect(_on_delete_deck)
	deck_list.item_selected.connect(_on_list_select)
	back.pressed.connect(_on_back)

func _check_button_states() -> void:
	new_deck_button.disabled = deck_data.size() >= MAX_DECKS
	edit_button.disabled = selected_index < 0
	delete_button.disabled = selected_index < 0

func load_decks() -> void:
	var data = DataUtils.load_data("user://decks.json")
	deck_data = data if typeof(data) == TYPE_ARRAY else []


func save_decks() -> void:
	DataUtils.save_data("user://decks.json", deck_data)

func display_decks() -> void:
	deck_list.clear()
	for deck in deck_data:
		var name = deck.get("name", "Unnamed Deck")
		var mode = deck.get("mode", "Unknown")
		deck_list.add_item("%s (%s)" % [name, mode])
	selected_index = -1
	_check_button_states()

func _on_list_select(index: int) -> void:
	selected_index = index
	_check_button_states()

func _on_new_deck() -> void:
	var popup = load(NEW_DECK_POPUP_PATH).instantiate()
	popup.parent_selector = self
	popup.is_edit_mode = false
	add_child(popup)
	popup.popup_centered()

func _on_edit_deck() -> void:
	if selected_index >= 0 and selected_index < deck_data.size():
		var popup = load(NEW_DECK_POPUP_PATH).instantiate()
		popup.parent_selector = self
		popup.is_edit_mode = true
		popup.edit_index = selected_index
		popup.populate_with_deck(deck_data[selected_index])
		add_child(popup)
		popup.popup_centered()

func _on_delete_deck() -> void:
	if selected_index >= 0:
		deck_data.remove_at(selected_index)
		save_decks()
		display_decks()

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
