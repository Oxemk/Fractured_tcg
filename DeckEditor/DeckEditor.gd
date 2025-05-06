# DeckEditor.gd
extends Control
class_name DeckEditor

@onready var deck_info_label: Label   = $DeckInfoLabel
@onready var card_grid: GridContainer = $CardPoolScroll2/VBoxContainer/CardGrid
@onready var card_pool: VBoxContainer = $CardPoolScroll/CardPool
@onready var save_button: Button      = $HBoxContainer/save

var current_deck: Dictionary = {}
var card_data: Dictionary = {}
var collection_manager: Node
var card_popup: CardPopup

var CardDatabase = preload("res://managers/CardDatabase.gd")

func _ready() -> void:
	print("--- DeckEditor ready ---")

	collection_manager = get_node_or_null("/root/CardCollectionManager")
	if not collection_manager:
		push_error("DeckEditor: CardCollectionManager missing!")
		return

	if not Globals.selected_deck or not Globals.selected_deck.has("cards"):
		push_error("DeckEditor: No valid deck in Globals.selected_deck")
		return
	current_deck = Globals.selected_deck

	# Load all cards
	card_data = CardDatabase.get_all_cards()
	if card_data.size() == 0:
		push_error("DeckEditor: card_data empty from CardDatabase!")

	save_button.pressed.connect(_on_save)

	# Popup
	card_popup = preload("res://Scenes/DeckEditor/CardPopup.tscn").instantiate()
	add_child(card_popup)
	card_popup.add_card_to_deck.connect(_on_card_added_to_deck)
	card_popup.remove_card_from_deck.connect(_on_card_removed_from_deck)

	display_deck()
	load_card_pool()

func display_deck() -> void:
	deck_info_label.text = "Editing Deck: %s [%s]" % [
		current_deck.get("name", "Unnamed"),
		current_deck.get("mode", "Unknown")
	]
	clear_children(card_grid)

	for cid in current_deck.get("cards", []):
		var data = card_data.get(cid, {})
		var btn = Button.new()
		btn.text = data.get("name", cid)
		btn.custom_minimum_size = Vector2(100, 40)
		btn.pressed.connect(func(id=cid): _on_card_removed_from_deck(id))
		card_grid.add_child(btn)

func load_card_pool() -> void:
	clear_children(card_pool)
	for cid in card_data.keys():
		var data = card_data[cid]
		var btn = Button.new()
		btn.text = data.get("name", cid)
		btn.custom_minimum_size = Vector2(100, 40)
		btn.pressed.connect(func(id=cid): _on_card_selected(id))
		card_pool.add_child(btn)

func _on_card_selected(cid: String) -> void:
	card_popup.setup(cid, card_data.get(cid, {}))
	card_popup.popup_centered()

func _on_card_added_to_deck(card_id: String) -> void:
	var cards = current_deck.get("cards", [])
	if cards.size() < int(current_deck.get("card_limit", 999)):
		cards.append(card_id)
		current_deck["cards"] = cards
		display_deck()

func _on_card_removed_from_deck(card_id: String) -> void:
	var cards = current_deck.get("cards", [])
	if card_id in cards:
		cards.erase(card_id)
		current_deck["cards"] = cards
		display_deck()

func _on_save() -> void:
	DeckManager.create_deck(current_deck)
	get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckSelector.tscn")

func clear_children(node: Node) -> void:
	if node:
		for c in node.get_children():
			c.queue_free()
