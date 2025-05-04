extends Node2D

# Reference to the TroopRow and other slots
@export var troop_row : Node2D
@export var troop_slot1 : Node2D
@export var troop_slot2 : Node2D
@export var troop_slot3 : Node2D

@export var bodyguard_zone : Node2D
@export var deckmaster_row : Node2D
@export var deck_zone : Node2D
@export var retired_zone : Node2D

# Variables to handle card setup and interactions
var weapon_cards = []
var armor_cards = []
var class_cards = []
var support_trap_cards = []

# Function to initialize or set up the player's board
func _ready():
	# Initialize the slots for Troops and Bodyguard
	initialize_troops()
	initialize_deck()

# Function to initialize troop slots
func initialize_troops():
	# Set up card texture or logic for the first TroopSlot
	troop_slot1.get_node("Weapon/weapcard").texture = preload("res://charcard.png")
	troop_slot1.get_node("Armor/Armcard").texture = preload("res://charcard.png")
	troop_slot1.get_node("Class/Classcard").texture = preload("res://charcard.png")

	# Similarly initialize the other troop slots
	troop_slot2.get_node("Weapon/weapcard").texture = preload("res://charcard.png")
	troop_slot2.get_node("Armor/Armcard").texture = preload("res://charcard.png")
	troop_slot2.get_node("Class/Classcard").texture = preload("res://charcard.png")

	troop_slot3.get_node("Weapon/weapcard").texture = preload("res://charcard.png")
	troop_slot3.get_node("Armor/Armcard").texture = preload("res://charcard.png")
	troop_slot3.get_node("Class/Classcard").texture = preload("res://charcard.png")

# Function to initialize the Deck zone and any retired cards
func initialize_deck():
	# Setup the Deck Zone for Player1 (or Player2 based on context)
	deck_zone.get_node("deck").texture = preload("res://charcard.png")
	retired_zone.get_node("Retired").texture = preload("res://charcard.png")

# Function to swap views for Player 1 or Player 2
func set_view(view: String):
	match view:
		"P1":
			self.position = Vector2(-183, 168)
			self.scale = Vector2(1.28428, 1.28428)
		"P2":
			self.position = Vector2(1339, 507)
			self.rotation = 3.14159
			self.scale = Vector2(1.28428, 1.28428)

# Function to handle any actions with the cards (for instance, removing or adding cards)
func handle_card_action(card: Sprite2D, action: String):
	match action:
		"remove":
			card.queue_free()
		"add":
			# Add logic to place a new card
			pass

# Function to handle deck interactions, like drawing cards, etc.
func draw_card_from_deck():
	# Logic to draw a card from the deck (add more logic as needed)
	var card = Sprite2D.new()
	card.texture = preload("res://charcard.png")
	deck_zone.add_child(card)
