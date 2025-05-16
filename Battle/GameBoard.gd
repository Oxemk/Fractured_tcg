extends Node2D
class_name GameBoard

var is_player_vs_ai: bool = true

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

# --- MODES & TURN OWNERS ---
enum GameMode { PVP, PVE }
var game_mode : GameMode = GameMode.PVE

enum TurnOwner { PLAYER1, PLAYER2, AI }
var current_turn_owner : TurnOwner = TurnOwner.PLAYER1

# --- TIMER & TURNS ---
@onready var tick_timer   : Timer = $TickTimer
var turn_count           : int   = 1
var turn_time_left       : int   = 120

# --- BOARDS & HANDS ---
@onready var PlayerBoard : Node   = $PlayerBoard
@onready var EnemyBoard  : Node   = $EnemyBoard
@onready var PlayerHand  : Node2D = $Player1/PlayerHand
@onready var EnemyHand   : Node2D = $Player2/PlayerHand

# --- BOARD SLOTS ---
@export var troop_slot1     : Node2D
@export var troop_slot2     : Node2D
@export var troop_slot3     : Node2D
@export var Bodyguard_Slot  : Node2D
@export var DeckMaster_Slot : Node2D
@export var deck_zone       : Node2D
@export var retired_zone    : Node2D

# --- GAME DATA ---
var p1_deck : Array = []
var p2_deck : Array = []
var ai_deck : Array = []
var draw_count_per_turn : int = 5
var target_pos : Vector2

func _ready() -> void:
	print("[GameBoard] _ready")
	_connect_phase_buttons()
	button_p1.pressed.connect(func(): switch_to_camera("p1"))
	button_p2.pressed.connect(func(): switch_to_camera("p2"))
	target_pos = cam_center.global_position
	cam_main.make_current()

	tick_timer.timeout.connect(_on_tick_timer_timeout)
	tick_timer.start()

	_load_config()

	p1_deck.shuffle()
	p2_deck.shuffle()
	ai_deck.shuffle()

	initialize_troops()
	initialize_deck()
	populate_hand(p1_deck, PlayerHand)
	if game_mode == GameMode.PVP:
		populate_hand(p2_deck, EnemyHand)
	else:
		populate_hand(ai_deck, EnemyHand)

	phase_manager = PhaseManager
	phase_manager.init(self)
	_start_new_turn()

func _load_config() -> void:
	# PvP vs PvE
	if Globals.vs_mode == 0:
		game_mode = GameMode.PVP
	else:
		game_mode = GameMode.PVE

	# Player 1 deck
	if Globals.p1_deck != null and typeof(Globals.p1_deck) == TYPE_DICTIONARY and Globals.p1_deck.has("cards"):
		p1_deck = Globals.p1_deck["cards"].duplicate()
	else:
		push_warning("GameBoard: No P1 deck selected; defaulting to empty")
		p1_deck = []

	# Player 2 or AI deck
	if game_mode == GameMode.PVP:
		if Globals.p2_deck != null and typeof(Globals.p2_deck) == TYPE_DICTIONARY and Globals.p2_deck.has("cards"):
			p2_deck = Globals.p2_deck["cards"].duplicate()
		else:
			push_warning("GameBoard: No P2 deck selected; defaulting to empty")
			p2_deck = []
	else:
		if Globals.p2_deck != null and typeof(Globals.p2_deck) == TYPE_DICTIONARY and Globals.p2_deck.has("cards"):
			ai_deck = Globals.p2_deck["cards"].duplicate()
		else:
			push_warning("GameBoard: No AI deck selected; using default")
			ai_deck = ["char_1", "weap_001", "armor_1", "trap_1", "support_1"]

func build_deck(ids: Array) -> Array:
	var deck := []
	for cid in ids:
		var data = _load_card_json(cid)
		if data.size() > 0:
			deck.append(cid)
	return deck

func build_ai_deck(_cfg: Dictionary) -> Array:
	if _cfg.has("cards"):
		return build_deck(_cfg.cards)
	return ["char_1", "weap_001", "armor_1", "trap_1", "support_1"]

func _start_new_turn() -> void:
	print("[GameBoard] Turn %d start" % turn_count)
	turn_time_left = 120
	_update_timer_label()
	_update_battle_button()

	# Alternate turn owner
	if game_mode == GameMode.PVP:
		if turn_count % 2 == 1:
			current_turn_owner = TurnOwner.PLAYER1
		else:
			current_turn_owner = TurnOwner.PLAYER2
	else:
		if turn_count % 2 == 1:
			current_turn_owner = TurnOwner.PLAYER1
		else:
			current_turn_owner = TurnOwner.AI

	phase_manager.reset(self)

	if turn_count == 1:
		phase_manager.force_phase(preload("res://phases/StartupPhase.gd"))
	else:
		phase_manager.force_phase(preload("res://phases/DrawPhase.gd"))

func _on_tick_timer_timeout() -> void:
	turn_time_left = max(0, turn_time_left - 1)
	_update_timer_label()
	if turn_time_left == 0:
		phase_manager.force_phase(preload("res://phases/EndPhase.gd"))

func _update_timer_label() -> void:
	var mins = turn_time_left / 60
	var secs = turn_time_left % 60
	label_timer.text = "%02d:%02d" % [mins, secs]

func _update_battle_button() -> void:
	btn_battle.disabled = turn_count < 2

func switch_to_camera(target: String) -> void:
	if target == "p1":
		cam_p1.make_current()
	elif target == "p2":
		cam_p2.make_current()
	else:
		cam_center.make_current()

func _connect_phase_buttons() -> void:
	btn_draw.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/DrawPhase.gd")))
	btn_standby.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/StandbyPhase.gd")))
	btn_main1.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/MainPhase.gd")))
	btn_battle.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/CombatPhase.gd")))
	btn_main2.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/MainPhase.gd")))
	btn_end.pressed.connect(func(): phase_manager.force_phase(preload("res://phases/EndPhase.gd")))

# --- Helpers ---
func draw_cards(count: int, is_player1: bool) -> void:
	var deck: Array
	var hand: Node2D

	if is_player1:
		deck = p1_deck
		hand = PlayerHand
	else:
		if game_mode == GameMode.PVP:
			deck = p2_deck
		else:
			deck = ai_deck
		hand = EnemyHand

	for i in range(count):
		if deck.size() == 0:
			push_warning("Deck is empty—cannot draw more cards")
			break
		var cid = deck.pop_front()
		var data = _load_card_json(cid)
		if data.size() == 0:
			continue
		var node = sCardLoader.load_card_data(data)
		if node:
			node.scale = Vector2(0.4, 0.4)
			hand.add_child(node)


func populate_hand(deck: Array, hand: Node2D) -> void:
	for child in hand.get_children():
		child.queue_free()
	for cid in deck:
		var data = _load_card_json(cid)
		if data.size() == 0:
			continue
		var node = sCardLoader.load_card_data(data)
		if node:
			node.scale = Vector2(0.4, 0.4)
			hand.add_child(node)

func initialize_troops() -> void:
	for slot in [troop_slot1, troop_slot2, troop_slot3]:
		if slot == null:
			slot = Node2D.new()
			add_child(slot)
	_populate_char_slot(Bodyguard_Slot,  "char_bodyguard_001")
	_populate_char_slot(DeckMaster_Slot, "char_deckmaster_001")

func initialize_deck() -> void:
	if deck_zone == null:
		deck_zone = Node2D.new(); add_child(deck_zone)
	if retired_zone == null:
		retired_zone = Node2D.new(); add_child(retired_zone)

func _populate_char_slot(slot: Node2D, id: String) -> void:
	if slot:
		var node = sCardLoader.load_card_data(_load_card_json(id))
		if node:
			slot.add_child(node)

func _load_card_json(id: String) -> Dictionary:
	return CardDatabase.cards.get(id, {})

func check_victory() -> bool:
	return PlayerBoard.get_child_count() == 0 or EnemyBoard.get_child_count() == 0

func display_victory() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
