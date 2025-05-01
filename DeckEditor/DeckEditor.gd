# DeckEditor.gd (updated)
extends Control
class_name DeckEditor

# Preload the CardPopup scene
const CARD_POPUP_SCENE = preload("res://Scenes/DeckEditor/CardPopup.tscn")

@onready var deck_info_label: Label   = $DeckInfoLabel
@onready var card_grid: GridContainer = $CardPoolScroll/CardGrid2
@onready var card_pool: GridContainer = $CardPoolScroll2/VBoxContainer/CardGrid
@onready var save_button: Button      = $HBoxContainer/save

var current_deck: Dictionary = {}
var card_data: Dictionary = {}
var collection_manager: Node
var card_popup: CardPopup


func _ready() -> void:
	print("--- DeckEditor ready ---")

	# Initialize collection manager
	collection_manager = get_node("/root/CardCollectionManager")
	if not collection_manager:
		push_error("Failed to find CardCollectionManager singleton!")
		return

	# Load the full card database from the autoload
	var db_node = get_node("/root/CardDatabase")
	if not db_node:
		push_error("CardDatabase autoload not found at /root/CardDatabase")
		return
	card_data = db_node.get_all_cards()  # or db_node.cards

	# Instantiate and hide CardPopup
	card_popup = CARD_POPUP_SCENE.instantiate()
	add_child(card_popup)
	card_popup.hide()

	# Display the pool and the current deck
	load_card_pool()
	display_deck()

	# Connect save button
	save_button.pressed.connect(_on_save)

func load_card_pool() -> void:
	var collection = collection_manager.get_collection()
	clear_children(card_pool)

	for cid in collection.keys():
		var data = card_data.get(cid)
		if not data:
			push_warning("Card data not found for ID: %s" % cid)
			continue

		var card_scene = CardLoader.load_card_data(data)  # use your autoload here
		if card_scene:
			card_scene.connect("gui_input", func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					_on_card_selected(cid)
			)
			card_pool.add_child(card_scene)
		else:
			push_warning("Card scene not loaded for ID: %s" % cid)

func display_deck() -> void:
	# Update deck info label
	deck_info_label.text = "Editing Deck: %s [%s]" % [
		current_deck.get("name", "Unnamed Deck"),
		current_deck.get("mode", "Unknown")
	]

	clear_children(card_grid)
	for cid in current_deck.get("cards", []):
		var data = card_data.get(cid)
		var lbl = Label.new()
		lbl.text = data.get("name", cid)
		card_grid.add_child(lbl)

func _on_card_selected(cid: String) -> void:
	var data = card_data.get(cid)
	if data:
		card_popup.setup(data)
		card_popup.popup_centered()

func _on_save() -> void:
	DeckManager.create_deck(current_deck)
	get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckSelector.tscn")

func clear_children(node: Node) -> void:
	if not node:
		push_error("clear_children(): Node is null!")
		return
	for child in node.get_children():
		child.queue_free()
