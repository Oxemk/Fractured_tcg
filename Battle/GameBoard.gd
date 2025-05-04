extends Node
class_name GameBoard
	
# --- CAMERA + UI ---
@onready var cam_main: Camera2D = $Camera2D_Main
@onready var cam_p1: Camera2D = $Camera2D_Player1
@onready var cam_p2: Camera2D = $Camera2D_Player2
@onready var cam_center: Camera2D = $Camera2D_Center

@onready var button_p1: Button = $CanvasLayer/Button_P1
@onready var button_p2: Button = $CanvasLayer/Button_P2
@onready var button_center: Button = $CanvasLayer/Button_Center
@onready var zoom_slider: HSlider = $CanvasLayer/ZoomSlider

var target_pos: Vector2
var target_zoom: Vector2

# --- GAME LOGIC ---
@onready var PlayerBoard = $PlayerBoard
@onready var EnemyBoard = $EnemyBoard
@onready var PlayerHand_P1 = $Player1/PlayerHand
@onready var PlayerHand_P2 = $Player2/PlayerHand
@onready var PlayerZone_P1 = $Player1
@onready var PlayerZone_P2 = $Player2

var config: Dictionary
var player_instances: Array = []
var ai_instances: Array = []
var current_player: int = 1  # 1 for Player 1, 2 for Player 2

func _ready() -> void:
	# --- CAMERA UI SETUP ---
	button_p1.pressed.connect(func(): switch_to_camera("p1"))
	button_p2.pressed.connect(func(): switch_to_camera("p2"))
	button_center.pressed.connect(func(): switch_to_camera("center"))
	zoom_slider.value_changed.connect(_on_zoom_changed)
	target_pos = cam_center.global_position
	target_zoom = Vector2(zoom_slider.value, zoom_slider.value)
	cam_main.make_current()

	# --- GAME SETUP ---
	config = Globals.selected_deck
	print(config)

	if config.has("cards"):
		for cid in config.cards:
			var card = CardLoader.load_card_data(_load_card_json(cid))
			PlayerBoard.add_child(card)
			player_instances.append(card)
	else:
		print("Error: 'cards' key not found in config")

	if config.has("ai_difficulty"):
		var ai_ids = AiManager.get_deck(config.ai_difficulty, config.mode)
		for cid in ai_ids:
			var card = CardLoader.load_card_data(_load_card_json(cid))
			EnemyBoard.add_child(card)
			ai_instances.append(card)

	_startup_phase()

func _process(delta: float) -> void:
	cam_main.global_position = cam_main.global_position.lerp(target_pos, delta * 5)
	cam_main.zoom = cam_main.zoom.lerp(target_zoom, delta * 5)

func switch_to_camera(target: String) -> void:
	match target:
		"p1":
			target_pos = cam_p1.global_position
			target_zoom = Vector2(1, 1)
		"p2":
			target_pos = cam_p2.global_position
			target_zoom = Vector2(1, 1)
		"center":
			target_pos = cam_center.global_position
			target_zoom = Vector2(zoom_slider.value, zoom_slider.value)

func _on_zoom_changed(value: float) -> void:
	if target_pos == cam_center.global_position:
		target_zoom = Vector2(value, value)

func _load_card_json(card_id: String) -> Dictionary:
	var file = FileAccess.open("res://cards/Data/card_database.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var data = json.parse(json_string)
		if data.error == OK:
			return data.result["cards"].get(card_id, {})
		else:
			print("Error parsing JSON:", data.error_string)
	return {}

func _startup_phase() -> void:
	var phase = preload("res://phases/StartupPhase.gd").new()
	add_child(phase)
	phase.start_phase(self)

func switch_to_turn() -> void:
	var phase = preload("res://phases/TurnPhase.gd").new()
	add_child(phase)
	phase.start_phase(self)

func switch_to_victory() -> void:
	var phase = preload("res://phases/VictoryPhase.gd").new()
	add_child(phase)
	phase.start_phase(self)

func check_victory() -> bool:
	return PlayerBoard.get_child_count() == 0 or EnemyBoard.get_child_count() == 0

func display_victory() -> void:
	get_tree().change_scene_to_file("res://main/MainMenu.tscn")
