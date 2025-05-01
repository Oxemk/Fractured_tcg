extends Node2D

@onready var cam_main: Camera2D = $Camera2D_Main
@onready var cam_p1: Camera2D = $Camera2D_Player1
@onready var cam_p2: Camera2D = $Camera2D_Player2
@onready var cam_center: Camera2D = $Camera2D_Center

@onready var button_p1: Button = $"CanvasLayer/Button_P1"
@onready var button_p2: Button = $"CanvasLayer/Button_P2"
@onready var button_center: Button = $"CanvasLayer/Button_Center"
@onready var zoom_slider: HSlider = $"CanvasLayer/ZoomSlider"

var target_pos: Vector2
var target_zoom: Vector2

func _ready() -> void:
	button_p1.pressed.connect(func() -> void: switch_to_camera("p1"))
	button_p2.pressed.connect(func() -> void: switch_to_camera("p2"))
	button_center.pressed.connect(func() -> void: switch_to_camera("center"))
	zoom_slider.value_changed.connect(_on_zoom_changed)
	target_pos = cam_center.global_position
	target_zoom = Vector2(zoom_slider.value, zoom_slider.value)
	cam_main.make_current()

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

func _process(delta: float) -> void:
	cam_main.global_position = cam_main.global_position.lerp(target_pos, delta * 5)
	cam_main.zoom = cam_main.zoom.lerp(target_zoom, delta * 5)
