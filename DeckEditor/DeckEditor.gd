extends Control
class_name DeckEditor

@onready var deck_info_label: Label   = $DeckInfoLabel
@onready var card_grid: GridContainer = $VBoxContainer/CardGrid
@onready var card_pool: VBoxContainer = $CardPoolScroll/CardPool
@onready var save_button: Button      = $HBoxContainer/save

var current_deck: Dictionary = {}
var card_data: Dictionary = {}
var collection_manager: Node
var card_popup: CardPopup

var CardDatabase = preload("res://managers/CardDatabase.gd")

func _ready() -> void:
	print("--- DeckEditor ready ---")

	# Initialize collection manager
	collection_manager = get_node("/root/CardCollectionManager")
	if not collection_manager:
		push_error("Failed to find CardCollectionManager singleton!")
		return

	# Ensure a deck has been selected
	if not Globals.selected_deck or not Globals.selected_deck.has("cards"):
		push_error("DeckEditor: No valid deck selected in Globals.selected_deck!")
		return
	current_deck = Globals.selected_deck
	print_debug("Current deck content: %s" % [JSON.stringify(current_deck)])

	# Load all cards from the database
	card_data = CardDatabase.get_all_cards()
	print_debug("Total cards in database: %d" % card_data.size())
	print_debug("Card data: %s" % [JSON.stringify(card_data)])
	if card_data.size() == 0:
		push_error("No cards loaded from database! Check card_database.json")

	# For testing, force unlock all cards; later use Globals.is_offline
	collection_manager.unlock_all_cards = true

	# Connect save button
	save_button.pressed.connect(_on_save)

	# Instantiate and add the CardPopup scene to the DeckEditor
	card_popup = preload("res://Scenes/DeckEditor/Cardpopup.tscn").instantiate()
	add_child(card_popup)

	# Populate UI
	display_deck()
	load_card_pool()

	# Connect signals for the popup
	card_popup.add_card_to_deck.connect(_on_card_added_to_deck)
	card_popup.remove_card_from_deck.connect(_on_card_removed_from_deck)

func display_deck() -> void:
	# Update deck info label
	var deck_name = current_deck.get("name", "Unnamed Deck")
	var mode = current_deck.get("mode", "Unknown")
	deck_info_label.text = "Editing Deck: %s [%s]" % [deck_name, mode]

	clear_children(card_grid)
	# Add a label for each card in the deck
	for cid in current_deck.get("cards", []):
		var data = card_data.get(cid)
		if typeof(data) != TYPE_DICTIONARY:
			push_warning("Card data for %s is not a Dictionary. Data: %s" % [cid, str(data)])
			data = {}
		var text = data.get("name", cid)
		var lbl = Label.new()
		lbl.text = text
		card_grid.add_child(lbl)

func load_card_pool() -> void:
	var coll = collection_manager.get_collection()
	print_debug("load_card_pool(): found %d cards" % coll.size())

	clear_children(card_pool)

	# Add a Button for each card in the collection
	for cid in coll.keys():
		var data = card_data.get(cid)
		if not data:
			push_warning("Card data not found for ID: %s" % cid)
			continue

		var btn_text = data.get("name", cid)
		var btn = Button.new()
		btn.text = btn_text

		# FIXED SIZE 100×40
		var sz = Vector2(100, 40)
		btn.custom_minimum_size = sz
		# Optionally shrink within its minimum bounds
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical   = Control.SIZE_SHRINK_CENTER

		# Connect button signal
		btn.pressed.connect(_on_card_selected.bind(cid))
		card_pool.add_child(btn)

	print_debug("CardPool contains %d buttons." % card_pool.get_child_count())

func _on_card_selected(cid: String) -> void:
	# When a card is selected, show the CardPopup
	var card_data = card_data.get(cid)
	if card_data:
		card_popup.setup(card_data)  # Setup the popup with the card data
		card_popup.popup_centered()  # Show the popup

func _on_card_added_to_deck(card_id: String) -> void:
	var cards = current_deck.get("cards", [])
	var limit = int(current_deck.get("card_limit", cards.size() + 1))
	if cards.size() < limit:
		cards.append(card_id)
		current_deck["cards"] = cards
		display_deck()
	else:
		print_debug("Reached card limit of %d" % limit)

func _on_card_removed_from_deck(card_id: String) -> void:
	var cards = current_deck.get("cards", [])
	if card_id in cards:
		cards.erase(card_id)
		current_deck["cards"] = cards
		display_deck()
	else:
		print_debug("Card not found in the deck")

func _on_save() -> void:
	DeckManager.create_deck(current_deck)
	get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckSelector.tscn")

func clear_children(node: Node) -> void:
	if not node:
		push_error("clear_children(): Node is null!")
		return
	for child in node.get_children():
		child.queue_free()
