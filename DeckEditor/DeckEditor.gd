extends Control
class_name DeckEditor

@onready var deck_info_label: Label   = $DeckInfoLabel
@onready var card_grid: GridContainer = $CardPoolScroll2/VBoxContainer/CardGrid
@onready var card_pool: VBoxContainer = $CardPoolScroll/CardPool
@onready var save_button: Button      = $HBoxContainer/save

var CARD_SCENE := preload("res://Scenes/DeckEditor/SmallCard.tscn")

var current_deck: Dictionary = {}
var card_data: Dictionary = {}
var collection_manager: Node
var card_popup: CardPopup

func _ready() -> void:
	print("--- DeckEditor ready ---")

	# Load card data from singleton
	card_data = CardDatabase.get_all_cards()
	print("🔍 [DEBUG] card_data contains %d entries." % card_data.size())

	if card_grid:
		card_grid.columns = 4
	else:
		push_error("DeckEditor: Cannot set columns, 'card_grid' is null.")

	print("🔍 [DEBUG] card_grid is %s | card_pool is %s" % [card_grid, card_pool])

	# Access required singletons
	collection_manager = CardCollectionManager
	if not collection_manager:
		push_error("DeckEditor: CardCollectionManager missing! Ensure autoloaded via Project Settings > Autoload.")
		return

	if not card_data or card_data.size() == 0:
		push_error("DeckEditor: card_data is empty from CardDatabase! Check _ready() logic or file path.")
		return

	if not Globals.selected_deck or not Globals.selected_deck.has("cards"):
		push_error("DeckEditor: No valid deck in Globals.selected_deck.")
		return

	# 🔧 FIX: Duplicate selected deck to prevent in-place edits
	current_deck = Globals.selected_deck.duplicate(true)
	if not current_deck.has("id") or current_deck["id"] == "":
		current_deck["id"] = str(Time.get_unix_time_from_system())

	# Connect save
	if save_button:
		save_button.pressed.connect(_on_save)
	else:
		push_error("DeckEditor: 'save' button not found, cannot connect signal.")

	# Setup popup
	card_popup = preload("res://Scenes/DeckEditor/CardPopup.tscn").instantiate()
	add_child(card_popup)
	card_popup.add_card_to_deck.connect(_on_card_added_to_deck)
	card_popup.remove_card_from_deck.connect(_on_card_removed_from_deck)

	display_deck()
	load_card_pool()

func display_deck() -> void:
	if deck_info_label:
		deck_info_label.text = "Editing Deck: %s [%s]" % [
			current_deck.get("name", "Unnamed"),
			current_deck.get("mode", "Unknown")
		]

	clear_children(card_grid)

	for cid in current_deck.get("cards", []):
		var data = card_data.get(cid, {})
		var card_ui = CARD_SCENE.instantiate()
		card_ui.setup(cid, data)
		card_ui.mouse_filter = Control.MOUSE_FILTER_PASS
		card_ui.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_card_removed_from_deck(cid)
		)
		card_grid.add_child(card_ui)

func load_card_pool() -> void:
	clear_children(card_pool)

	for cid in card_data.keys():
		var data = card_data[cid]
		var card_ui = CARD_SCENE.instantiate()
		card_ui.setup(cid, data)
		card_ui.mouse_filter = Control.MOUSE_FILTER_PASS
		card_ui.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_card_selected(cid)
		)
		card_pool.add_child(card_ui)

func _on_card_selected(cid: String) -> void:
	card_popup.setup(cid, card_data.get(cid, {}), current_deck.get("cards", []))
	card_popup.popup_centered()

func _on_card_added_to_deck(card_id: String) -> void:
	var cards = current_deck.get("cards", [])
	if cards.size() < int(current_deck.get("card_limit", 999)) and not cards.has(card_id):
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
	# 🔧 FIX: Use the singleton instance, not preload
	DeckManager.create_deck(current_deck)
	get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckSelector.tscn")

func clear_children(node: Node) -> void:
	if node == null:
		push_error("DeckEditor: clear_children called on a null node.")
		return
	for c in node.get_children():
		c.queue_free()
