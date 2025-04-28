# res://Scenes/DeckEditor/DeckEditor.gd
extends Control
class_name DeckEditor

@onready var deck_info_label: Label   = $DeckInfoLabel
@onready var card_grid: GridContainer = $VBoxContainer/CardGrid
@onready var card_pool: VBoxContainer = $CardPoolScroll/CardPool
@onready var save_button: Button      = $HBoxContainer/save

var current_deck: Dictionary = {}
var card_data: Dictionary = {}
var collection_manager: Node

# Preload the CardDatabase script
var CardDatabase = preload("res://managers/CardDatabase.gd")

func _ready() -> void:
	print("--- DeckEditor ready ---")

	# Initialize collection manager
	collection_manager = $"/root/CardCollectionManager"
	if not collection_manager:
		push_error("Failed to find CardCollectionManager singleton!")
		return

	# Ensure a deck has been selected
	if not Globals.selected_deck or not Globals.selected_deck.has("cards"):
		push_error("DeckEditor: No valid deck selected in Globals.selected_deck!")
		return
	current_deck = Globals.selected_deck
	print_debug("Current deck content: ", JSON.stringify(current_deck))

	# Load all cards from the database
	card_data = CardDatabase.get_all_cards()
	print_debug("Total cards in database: %d" % card_data.size())
	print_debug("Card data: ", JSON.stringify(card_data))
	
	if card_data.size() > 0:
		print_debug("Sample card keys: ", card_data.keys().slice(0, min(5, card_data.size())))
	else:
		push_error("No cards loaded from database! Check card_database.json")

	# For testing, force unlock all cards; later use Globals.is_offline
	collection_manager.unlock_all_cards = true

	# Connect save button
	save_button.pressed.connect(_on_save)

	# Populate UI
	display_deck()
	load_card_pool()

func display_deck() -> void:
	# Update deck info label
	var deck_name = current_deck.get("name", "Unnamed Deck")
	var mode = current_deck.get("mode", "Unknown")
	deck_info_label.text = "Editing Deck: %s [%s]" % [deck_name, mode]

	clear_children(card_grid)
	# Add a label for each card in the deck
	for cid in current_deck.get("cards", []):
		var data = card_data.get(cid)
		var text = data.get("name", cid) if data and data.has("name") else cid
		var lbl = Label.new()
		lbl.text = text
		card_grid.add_child(lbl)

func load_card_pool() -> void:
	var coll = collection_manager.get_collection()
	print_debug("load_card_pool(): found %d cards" % coll.size())

	clear_children(card_pool)
	for cid in coll.keys():
		var data = card_data.get(cid)
		var btn_text = data.get("name", cid) if data and data.has("name") else cid
		var btn = Button.new()
		btn.text = btn_text
		btn.pressed.connect(_on_card_selected.bind(cid))
		card_pool.add_child(btn)

func _on_card_selected(cid: String) -> void:
	var cards = current_deck.get("cards", [])
	var limit = int(current_deck.get("card_limit", cards.size() + 1))
	if cards.size() < limit:
		cards.append(cid)
		current_deck["cards"] = cards
		display_deck()
	else:
		print_debug("Reached card limit of %d" % limit)

func _on_save() -> void:
	DeckManager.create_deck(current_deck)
	get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckSelector.tscn")

func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
