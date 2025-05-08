extends Node2D

# Reference to the Rows and other slots
@export var troop_row        : Node2D
@export var bodyguard_zone   : Node2D
@export var deckmaster_row   : Node2D
@export var deckmaster_slot  : Node2D
@export var deck_zone        : Node2D
@export var retired_zone     : Node2D
@export var troop_slot1      : Node2D
@export var troop_slot2      : Node2D
@export var troop_slot3      : Node2D

# Variables to handle card setup and interactions
var weapon_cards        = []
var armor_cards         = []
var class_cards         = []
var support_trap_cards  = []

func _ready():
	initialize_troops()
	initialize_deck()

func safe_get_node(base: Node, path: String) -> Node:
	if base and base.has_node(path):
		return base.get_node(path)
	else:
		push_warning("Missing node at path: '%s' in %s" % [path, base])
		return null

func initialize_troops():
	var troop_slots = [troop_slot1, troop_slot2, troop_slot3]
	for i in range(troop_slots.size()):
		var slot = troop_slots[i]
		if slot == null:
			push_warning("Troop slot %d is null." % i)
			continue

		var weap = safe_get_node(slot, "Weapon/weapcard") as Sprite2D
		var arm  = safe_get_node(slot, "Armor/Armcard") as Sprite2D
		var cls  = safe_get_node(slot, "Class/Classcard") as Sprite2D

		if weap: weap.texture = preload("res://charcard.png")
		if arm:  arm.texture  = preload("res://charcard.png")
		if cls:  cls.texture  = preload("res://charcard.png")

func initialize_deck():
	if deck_zone:
		var deck = safe_get_node(deck_zone, "deck") as Sprite2D
		if deck:
			deck.texture = preload("res://charcard.png")
		else:
			push_warning("deck sprite not found inside deck_zone")
	else:
		push_warning("deck_zone is null.")

	if retired_zone:
		var retired = safe_get_node(retired_zone, "Retired") as Sprite2D
		if retired:
			retired.texture = preload("res://charcard.png")
		else:
			push_warning("retired sprite not found inside retired_zone")
	else:
		push_warning("retired_zone is null.")

func set_view(view: String):
	match view:
		"P1":
			position = Vector2(-183, 168)
			scale    = Vector2(1.28428, 1.28428)
		"P2":
			position = Vector2(1339, 507)
			rotation = PI
			scale    = Vector2(1.28428, 1.28428)
		_:
			push_warning("Unknown view: %s" % view)

func handle_card_action(card: Sprite2D, action: String):
	match action:
		"remove":
			if card:
				card.queue_free()
			else:
				push_warning("No card to remove.")
		"add":
			push_warning("Add logic not implemented.")
		_:
			push_warning("Unknown action: %s" % action)

func draw_card_from_deck():
	var card = Sprite2D.new()
	card.texture = preload("res://charcard.png")
	if deck_zone:
		deck_zone.add_child(card)
	else:
		push_warning("Cannot draw card: deck_zone is null.")
