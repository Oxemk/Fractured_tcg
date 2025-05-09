# MainMenu.gd
# Location: res://Scenes/MainMenu/MainMenu.tscn (attach to Control root)
extends Control
class_name MainMenu

# Main menu buttons (match your node names)
@onready var story_btn    := $HBoxContainer/Menu/story_button
@onready var casual_btn   := $HBoxContainer/Menu/casual_button
@onready var ranked_btn   := $HBoxContainer/Menu/ranked_button
@onready var settings_btn := $HBoxContainer/Menu/settings_button
@onready var profile_btn  := $HBoxContainer/Menu/profile_button
@onready var mode_lbl     := $HBoxContainer/Menu/mode_label
@onready var quit_btn     := $HBoxContainer/Menu/Quit_button

# First submenu (after picking mode)
@onready var sub1         := $HBoxContainer/SubMenuContainer
@onready var back1_btn    := $HBoxContainer/SubMenuContainer/Backb
@onready var shop_btn     := $HBoxContainer/SubMenuContainer/Shop_Button
@onready var coll_btn     := $HBoxContainer/SubMenuContainer/Collection_Button
@onready var deck_btn     := $HBoxContainer/SubMenuContainer/DeckEditor_Button
@onready var play_btn     := $HBoxContainer/SubMenuContainer/PlayButton

# Second submenu (after pressing Play)
@onready var sub2         := $HBoxContainer/SubMenuContainer2
@onready var back2_btn    := $HBoxContainer/SubMenuContainer2/Backb
@onready var p1p2_btn     := $HBoxContainer/SubMenuContainer2/P1vsP2_Button
@onready var vscomp_btn   := $HBoxContainer/SubMenuContainer2/VSComputer_Button

func _ready() -> void:
	# Verify nodes
	if not story_btn or not casual_btn or not ranked_btn:
		push_error("MainMenu: missing UI nodes; verify node names in scene tree.")
		return
	# Connect main menu signals
	story_btn.pressed.connect(_on_story)
	casual_btn.pressed.connect(_on_casual)
	ranked_btn.pressed.connect(_on_ranked)
	settings_btn.pressed.connect(_on_settings)
	profile_btn.pressed.connect(_on_profile)
	quit_btn.pressed.connect(_on_quit)
	# Connect first submenu signals
	shop_btn.pressed.connect(_on_shop)
	coll_btn.pressed.connect(_on_collection)
	deck_btn.pressed.connect(_on_deckeditor)
	play_btn.pressed.connect(_on_play)
	back1_btn.pressed.connect(_on_back1)
	# Connect second submenu signals
	p1p2_btn.pressed.connect(_on_p1p2)
	vscomp_btn.pressed.connect(_on_vscomp)
	back2_btn.pressed.connect(_on_back2)

	_update_mode_ui()
	sub1.visible = false
	sub2.visible = false

func _update_mode_ui() -> void:
	mode_lbl.text = "Mode: %s" % Globals.current_mode.capitalize()
	profile_btn.disabled = Globals.is_offline
	ranked_btn.disabled = Globals.is_offline

func _on_story() -> void:
	Globals.current_mode = "story"
	_show_sub1()

func _on_casual() -> void:
	Globals.current_mode = "casual"
	_show_sub1()

func _on_ranked() -> void:
	if Globals.is_offline:
		push_warning("Ranked disabled offline")
	else:
		Globals.current_mode = "ranked"
		_show_sub1()

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")

func _on_profile() -> void:
	if not Globals.is_offline:
		get_tree().change_scene_to_file("res://Scenes/MainMenu/CardCollection.tscn")

func _on_quit() -> void:
	get_tree().quit()

func _show_sub1() -> void:
	$HBoxContainer/Menu.visible = false
	sub1.visible = true

func _on_back1() -> void:
	sub1.visible = false
	$HBoxContainer/Menu.visible = true

func _on_shop() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/shop.tscn" % Globals.current_mode.capitalize())

func _on_collection() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/CardCollection.tscn" % Globals.current_mode.capitalize())

func _on_deckeditor() -> void:
	get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckSelector.tscn")

func _on_play() -> void:
	sub1.visible = false
	sub2.visible = true

func _on_back2() -> void:
	sub2.visible = false
	sub1.visible = true


func _on_p1p2() -> void:
	Globals.vs_mode = Globals.VSMode.P1vsP2
	get_tree().change_scene_to_file("res://Scenes/Battle/VSDeckSelector.tscn")

func _on_vscomp() -> void:
	Globals.vs_mode = Globals.VSMode.P1vsComputer
	get_tree().change_scene_to_file("res://Scenes/Battle/VSDeckSelector.tscn")
