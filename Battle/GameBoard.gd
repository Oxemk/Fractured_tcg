# GameBoard.gd
extends Node
class_name GameBoard

# --- CAMERA + UI ---
@onready var cam_main   : Camera2D = $Camera2D_Main
@onready var cam_p1     : Camera2D = $Camera2D_Player1
@onready var cam_p2     : Camera2D = $Camera2D_Player2
@onready var cam_center : Camera2D = $Camera2D_Center

@onready var button_p1     : Button = $CanvasLayer/Button_P1
@onready var button_p2     : Button = $CanvasLayer/Button_P2
@onready var button_center : Button = $CanvasLayer/Button_Center

var target_pos: Vector2

# --- ZONES & HANDS ---
@onready var PlayerBoard : Node = $PlayerBoard
@onready var EnemyBoard  : Node = $EnemyBoard
@onready var PlayerHand  : Node = $Player1/PlayerHand
@onready var EnemyHand   : Node = $Player2/PlayerHand

# --- DECK STORAGE ---
var player_deck: Array = []
var ai_deck    : Array = []

# --- CONFIG & INSTANCES ---
var config: Dictionary
var player_instances: Array = []
var ai_instances: Array = []
var current_player: int = 1
var is_turn_in_progress: bool = false

# --- DRAW SETTINGS ---
var draw_count_per_turn: int = 5

# --- PHASE TRACKING ---
var current_phase: Node = null

func _ready() -> void:
	# Camera button setup
	button_p1.pressed.connect(func(): switch_to_camera("p1"))
	button_p2.pressed.connect(func(): switch_to_camera("p2"))
	button_center.pressed.connect(func(): switch_to_camera("center"))
	target_pos = cam_center.global_position
	cam_main.make_current()

	# Determine config: use selected_deck if valid, otherwise fallback
	if Globals.selected_deck and Globals.selected_deck.has("cards") and Globals.selected_deck["cards"] is Array and Globals.selected_deck["cards"].size() > 0:
		config = Globals.selected_deck
	else:
		config = {}
		# Fallback: player deck
		if Globals.p1_deck and Globals.p1_deck.has("cards") and Globals.p1_deck.cards is Array:
			config["cards"] = Globals.p1_deck.cards
		else:
			config["cards"] = []
		# Fallback: mode
		if Globals.selected_deck and Globals.selected_deck.has("mode"):
			config["mode"] = Globals.selected_deck.mode
		else:
			config["mode"] = Globals.current_mode
		# Fallback: ai difficulty
		if Globals.p2_deck and Globals.p2_deck.has("level"):
			config["ai_difficulty"] = Globals.p2_deck.level
		else:
			config["ai_difficulty"] = null

	print("DEBUG: Final Config Loaded: %s" % str(config))

	# Validate config
	if not config.has("cards") or not config["cards"] is Array:
		push_error("Invalid deck config: %s" % str(config))
		return

	# Build player_deck raw data
	for cid in config.cards:
		var data = _load_card_json(cid)
		if typeof(data) == TYPE_DICTIONARY and data.size() > 0:
			player_deck.append(data)
		else:
				push_error("Invalid or missing card data for ID '%s'; skipping." % cid)

	# Build ai_deck if difficulty & mode are present
	if config.has("ai_difficulty") and config["ai_difficulty"] and config.has("mode"):
		var diff = config["ai_difficulty"]
		var mode = config["mode"]
		if typeof(diff) != TYPE_STRING:
			push_warning("ai_difficulty is not a string, skipping AI deck generation: %s" % str(diff))
		else:
			var ai_ids = AiManager.get_deck(diff, mode)
			for cid in ai_ids:
				var data = _load_card_json(cid)
				if typeof(data) == TYPE_DICTIONARY and data.size() > 0:
					ai_deck.append(data)
				else:
					push_error("Invalid or missing AI card data for ID '%s'; skipping." % cid)
	else:
		push_warning("Skipping AI deck generation: ai_difficulty or mode missing in config: %s" % str(config))

	# Shuffle decks
	player_deck.shuffle()
	ai_deck.shuffle()

	# Start game flow
	_startup_phase()

func _process(delta: float) -> void:
	cam_main.global_position = cam_main.global_position.lerp(target_pos, delta * 5)

func switch_to_camera(target: String) -> void:
	match target:
		"p1":
			target_pos = cam_p1.global_position
		"p2":
			target_pos = cam_p2.global_position
		"center":
			target_pos = cam_center.global_position
		_:
			push_warning("Unknown camera target: %s" % target)

# --- PUBLIC INTERFACE ---
func draw_cards(count: int, is_player: bool = true) -> void:
	var deck = player_deck if is_player else ai_deck
	var hand = PlayerHand   if is_player else EnemyHand

	# Only draw up to the number of cards left
	var actual_draw = min(count, deck.size())
	for i in range(actual_draw):
		var data = deck.pop_front()
		if typeof(data) != TYPE_DICTIONARY or data.size() == 0:
			push_error("Tried to draw invalid card data; skipping.")
			continue

		var card = CardLoader.load_card_data(data)
		if card:
			hand.add_child(card)
		else:
			push_error("CardLoader failed to instantiate card for data: %s" % str(data))

func enable_combat_ui() -> void:
	# placeholder for combat UI logic
	pass

func cleanup_end_phase() -> void:
	# placeholder for end-phase cleanup
	pass

func check_victory() -> bool:
	if PlayerBoard.get_child_count() == 0:
		print("Player has no cards left.")
		return true
	if EnemyBoard.get_child_count() == 0:
		print("Enemy has no cards left.")
		return true
	return false

func display_victory() -> void:
	print("Victory! Returning to main menu.")
	get_tree().change_scene_to_file("res://main/MainMenu.tscn")

# --- INTERNAL: LOADING & PHASE SWITCHING ---
func _load_card_json(card_id: String) -> Dictionary:
	var file = FileAccess.open("res://Data/card_database.json", FileAccess.READ)
	if not file:
		push_error("Could not open card database file.")
		return {}

	var js = JSON.new()
	if js.parse(file.get_as_text()) != OK:
		push_error("Failed to parse card database JSON.")
		return {}

	var db = js.get_data()
	if db.has("cards") and db.cards.has(card_id):
		return db.cards[card_id]

	push_error("Card ID '%s' not found in database." % card_id)
	return {}

func _startup_phase() -> void:
	var phase = preload("res://phases/StartupPhase.gd").new()
	switch_to_phase(phase)

func switch_to_phase(phase_node: Node) -> void:
	if not phase_node:
		push_error("Attempted to switch to a null phase.")
		return

	# Clean up old phase
	if current_phase and current_phase.is_inside_tree():
		remove_child(current_phase)
		current_phase.queue_free()

	# Add new phase
	add_child(phase_node)
	current_phase = phase_node

	# Defer starting the phase to avoid stack overflow
	phase_node.call_deferred("start_phase", self)
