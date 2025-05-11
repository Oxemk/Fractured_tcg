extends Node2D
class_name GameBoard

# --- UI PHASE BAR ---
@onready var btn_draw    : Button = $CanvasLayer/PhaseBar/Button_Draw
@onready var btn_standby : Button = $CanvasLayer/PhaseBar/Button_Standby
@onready var btn_main1   : Button = $CanvasLayer/PhaseBar/Button_Main1
@onready var btn_battle  : Button = $CanvasLayer/PhaseBar/Button_Battle
@onready var btn_main2   : Button = $CanvasLayer/PhaseBar/Button_Main2
@onready var btn_end     : Button = $CanvasLayer/PhaseBar/Button_End
@onready var label_timer : Label  = $CanvasLayer/PhaseBar/Label_Timer

# --- CAMERA & UI ---
@onready var cam_main   : Camera2D = $Camera2D_Main
@onready var cam_p1     : Camera2D = $Camera2D_Player1
@onready var cam_p2     : Camera2D = $Camera2D_Player2
@onready var cam_center : Camera2D = $Camera2D_Center
@onready var button_p1  : Button   = $CanvasLayer/Button_P1
@onready var button_p2  : Button   = $CanvasLayer/Button_P2

# --- PHASE MANAGER ---
var phase_manager: PhaseManager


# --- TIMER & TURNS ---
@onready var tick_timer : Timer = $TickTimer
var turn_count          : int = 1
var turn_time_left      : int = 120

# --- BOARDS & HANDS ---
@onready var PlayerBoard : Node = $PlayerBoard
@onready var EnemyBoard  : Node = $EnemyBoard
@onready var PlayerHand  : Node = $Player1/PlayerHand
@onready var EnemyHand   : Node = $Player2/PlayerHand

# --- BOARD SLOTS ---
@export var troop_slot1     : Node2D
@export var troop_slot2     : Node2D
@export var troop_slot3     : Node2D
@export var Bodyguard_Slot  : Node2D
@export var DeckMaster_Slot : Node2D
@export var deck_zone       : Node2D
@export var retired_zone    : Node2D

# --- GAME DATA ---
var player_deck        : Array = []
var ai_deck            : Array = []
var config             : Dictionary
var draw_count_per_turn: int = 5
var target_pos         : Vector2

func _ready() -> void:
	# Remove the call to reset here
	# phase_manager.reset(self)  # Remove this line

	print("[GameBoard] _ready")

	# Setup UI & Cameras
	_connect_phase_buttons()
	button_p1.pressed.connect(func(): switch_to_camera("p1"))
	button_p2.pressed.connect(func(): switch_to_camera("p2"))
	target_pos = cam_center.global_position
	cam_main.make_current()

	# Timer
	tick_timer.timeout.connect(self._on_tick_timer_timeout)
	tick_timer.start()

	# Game Initialization
	_load_config()
	player_deck = build_deck(config.cards)
	ai_deck = build_ai_deck(config)
	player_deck.shuffle()
	ai_deck.shuffle()
	initialize_troops()
	initialize_deck()
	populate_hand(player_deck, PlayerHand)
	populate_hand(ai_deck, EnemyHand)

	_start_new_turn()

	# Game Initialization
	_load_config()
	player_deck = build_deck(config.cards)
	ai_deck = build_ai_deck(config)
	player_deck.shuffle()
	ai_deck.shuffle()
	initialize_troops()
	initialize_deck()
	populate_hand(player_deck, PlayerHand)
	populate_hand(ai_deck, EnemyHand)

	_start_new_turn()

func _start_new_turn() -> void:
	print("[GameBoard] Turn %d start" % turn_count)
	turn_time_left = 120
	_update_timer_label()
	_update_battle_button()
	phase_manager.reset(self)



func _on_tick_timer_timeout() -> void:
	turn_time_left = max(0, turn_time_left - 1)
	_update_timer_label()
	if turn_time_left == 0:
		print("[GameBoard] Turn timer expired")
		phase_manager.force_phase(preload("res://phases/EndPhase.gd"))

func _update_timer_label() -> void:
	label_timer.text = "%02d:%02d" % [turn_time_left / 60, turn_time_left % 60]

func _update_battle_button() -> void:
	btn_battle.disabled = turn_count < 2

func switch_to_camera(target: String) -> void:
	match target:
		"p1": target_pos = cam_p1.global_position
		"p2": target_pos = cam_p2.global_position
		"center": target_pos = cam_center.global_position
		_: push_warning("Unknown camera: %s" % target)

func _connect_phase_buttons() -> void:
	btn_draw.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/DrawPhase.gd")))
	btn_standby.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/StandbyPhase.gd")))
	btn_main1.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/MainPhase.gd")))
	btn_battle.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/CombatPhase.gd")))
	btn_main2.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/MainPhase.gd")))
	btn_end.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/EndPhase.gd")))

# -------------------------------
# Helper Functions
# -------------------------------

func _load_config() -> void:
	if Globals.p1_deck is Dictionary and Globals.p1_deck.has("cards"):
		config = Globals.p1_deck.duplicate()
		config["mode"] = Globals.p1_deck.get("mode", Globals.current_mode)
		config["ai_difficulty"] = Globals.p2_deck.get("level", "easy")
	else:
		config = {"cards": [], "mode": Globals.current_mode, "ai_difficulty": "easy"}

func draw_cards(count: int, is_player: bool = true) -> void:
	var deck = player_deck if is_player else ai_deck
	var hand = PlayerHand if is_player else EnemyHand
	for i in range(min(count, deck.size())):
		var cid = deck.pop_front()
		var data = _load_card_json(cid)
		if data.size() == 0:
			push_error("No data for %s" % cid)
			continue
		var node = CardLoader.load_card_data(data)
		if node:
			hand.add_child(node)
		else:
			push_error("Instantiate failed %s" % cid)

func build_deck(ids: Array) -> Array:
	var deck := []
	for cid in ids:
		if typeof(cid) == TYPE_STRING and _load_card_json(cid).size() > 0:
			deck.append(cid)
	return deck

func build_ai_deck(cfg: Dictionary) -> Array:
	match cfg.get("ai_difficulty", "easy"):
		"easy":   return ["char_1","weapon_1","armor_1","trap_1","support_1"]
		"medium": return ["char_2","weapon_2","armor_2","trap_2","support_2"]
		"hard":   return ["char_3","weapon_3","armor_3","trap_3","support_3"]
		_:        push_warning("Unknown AI difficulty %s" % cfg.get("ai_difficulty")); return []

func populate_hand(deck: Array, hand: Node) -> void:
	for cid in deck:
		var node = CardLoader.load_card_data(_load_card_json(cid))
		if node:
			hand.add_child(node)

func initialize_troops() -> void:
	print("[InitTroops] Setting up character slots")
	var slots = [troop_slot1, troop_slot2, troop_slot3]
	for i in range(slots.size()):
		if not slots[i]:
			slots[i] = Node2D.new(); add_child(slots[i])
	_populate_char_slot(Bodyguard_Slot,  "char_bodyguard_001")
	_populate_char_slot(DeckMaster_Slot, "char_deckmaster_001")

func initialize_deck() -> void:
	if not deck_zone:    deck_zone = Node2D.new(); add_child(deck_zone)
	if not retired_zone: retired_zone = Node2D.new(); add_child(retired_zone)

func _populate_char_slot(slot: Node2D, id: String) -> void:
	if slot:
		var node = CardLoader.load_card_data(_load_card_json(id))
		if node:
			slot.add_child(node)

func _load_card_json(id: String) -> Dictionary:
	var f = FileAccess.open("res://data/card_database.json", FileAccess.READ)
	if not f:
		push_error("Cannot open DB"); return {}
	var txt = f.get_as_text(); f.close()
	var js = JSON.new()
	if js.parse(txt) != OK:
		push_error("JSON.parse error: %s" % js.error_string); return {}
	var db = js.get_data()
	for cat in db.keys():
		for c in db[cat]:
			if c.get("id", "") == id:
				return c
	return {}

func enable_combat_ui() -> void:
	print("CombatPhase started—no UI to show")

func cleanup_end_phase() -> void:
	print("EndPhase cleanup (stub)")

func check_victory() -> bool:
	return PlayerBoard.get_child_count() == 0 or EnemyBoard.get_child_count() == 0

func display_victory() -> void:
	print("Victory!")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
