extends Node2D
class_name GameBoard

# --- CAMERA + UI ---
@onready var cam_main    : Camera2D = $Camera2D_Main
@onready var cam_p1      : Camera2D = $Camera2D_Player1
@onready var cam_p2      : Camera2D = $Camera2D_Player2
@onready var cam_center  : Camera2D = $Camera2D_Center

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
var current_player: int = 1

# --- DRAW SETTINGS ---
var draw_count_per_turn: int = 5

# --- PHASE TRACKING ---
var current_phase: Node = null

func _ready() -> void:
	# Camera buttons
	button_p1.pressed.connect(func(): switch_to_camera("p1"))
	button_p2.pressed.connect(func(): switch_to_camera("p2"))
	button_center.pressed.connect(func(): switch_to_camera("center"))
	target_pos = cam_center.global_position
	cam_main.make_current()

	# Load or default config
	if Globals.p1_deck is Dictionary and Globals.p1_deck.has("cards") and typeof(Globals.p1_deck.cards) == TYPE_ARRAY:
		config = Globals.p1_deck.duplicate()
		config["mode"] = Globals.p1_deck.get("mode", Globals.current_mode)
		config["ai_difficulty"] = Globals.p2_deck.get("level", "easy")
	else:
		config = {
			"cards": [],
			"mode": Globals.current_mode,
			"ai_difficulty": "easy",
		}

	# Build & shuffle
	player_deck = build_deck(config.cards)
	ai_deck     = build_ai_deck(config)
	player_deck.shuffle()
	ai_deck.shuffle()

	# Start phases
	switch_to_phase(preload("res://phases/StartupPhase.gd").new())

func _process(delta: float) -> void:
	cam_main.global_position = cam_main.global_position.lerp(target_pos, delta * 5)

func switch_to_camera(target: String) -> void:
	match target:
		"p1":     target_pos = cam_p1.global_position
		"p2":     target_pos = cam_p2.global_position
		"center": target_pos = cam_center.global_position
		_: push_warning("Unknown camera target: %s" % target)

# --- PHASE HANDLING ---
func switch_to_phase(new_phase: Node) -> void:
	if current_phase:
		current_phase.queue_free()
	current_phase = new_phase
	add_child(current_phase)
	# Defer the start_phase call so it happens after this function returns
	current_phase.call_deferred("start_phase", self)

# --- PUBLIC INTERFACE / PHASE HOOKS ---
func enable_combat_ui() -> void:
	# Called by CombatPhase to show combat UI elements
	# e.g. enable attack buttons, highlight units, etc.
	pass

func cleanup_end_phase() -> void:
	# Called by EndPhase to clear any temporary state (e.g. remove highlights)
	pass

# --- CARD DRAWING ---
func draw_cards(count: int, is_player: bool = true) -> void:
	var deck = player_deck if is_player else ai_deck
	var hand = PlayerHand    if is_player else EnemyHand

	count = min(count, deck.size())
	for i in range(count):
		var card_id = deck.pop_front()
		if typeof(card_id) != TYPE_STRING:
			push_warning("Invalid card ID: %s" % str(card_id))
			continue
		var data = _load_card_json(card_id)
		if data.is_empty():
			push_warning("No data for card ID: %s" % card_id)
			continue
		var node = CardLoader.load_card_data(data)
		if node and is_instance_valid(node):
			hand.add_child(node)
		else:
			push_error("Failed to instantiate card: %s" % card_id)

# --- VICTORY CHECK ---
func check_victory() -> bool:
	return PlayerBoard.get_child_count() == 0 or EnemyBoard.get_child_count() == 0

func display_victory() -> void:
	print("Victory!")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

# --- DECK BUILDING ---
func build_deck(ids: Array) -> Array:
	var deck: Array = []
	for cid in ids:
		if typeof(cid) != TYPE_STRING:
			continue
		var data = _load_card_json(cid)
		if not data.is_empty():
			deck.append(cid)
	return deck

func build_ai_deck(_Scfg: Dictionary) -> Array:
	var deck: Array = []
	# TODO: implement AI deck logic here based on cfg["ai_difficulty"] & cfg["mode"]
	return deck

# --- JSON LOADER ---
func _load_card_json(id: String) -> Dictionary:
	var path = "res://data/card_database.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("Cannot open card DB: %s" % path)
		return {}
	var text = file.get_as_text()
	file.close()

	var parser = JSON.new()
	var err = parser.parse(text)
	if err != OK:
		push_warning("JSON parse error %s: %s" % [path, parser.error_string])
		return {}

	var db = parser.get_data()
	for category in db.keys():
		for card in db[category]:
			if card.get("id", "") == id:
				return card
	return {}

# --- HELPER TO KICK OFF STARTUP (optional) ---
func _startup_phase() -> void:
	switch_to_phase(preload("res://phases/StartupPhase.gd").new())
