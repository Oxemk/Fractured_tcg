extends Control
class_name MainMenu

@onready var story_btn    := $HBoxContainer/Menu/story_button
@onready var casual_btn   := $HBoxContainer/Menu/casual_button
@onready var ranked_btn   := $HBoxContainer/Menu/ranked_button
@onready var settings_btn := $HBoxContainer/Menu/settings_button
@onready var profile_btn  := $HBoxContainer/Menu/profile_button
@onready var mode_lbl     := $HBoxContainer/Menu/mode_label
@onready var quit_btn     := $HBoxContainer/Menu/Quit_button

@onready var sub_menu   := $HBoxContainer/SubMenuContainer
@onready var back_btn   := $HBoxContainer/SubMenuContainer/Backb
@onready var shop_btn   := $HBoxContainer/SubMenuContainer/Shop_Button
@onready var coll_btn   := $HBoxContainer/SubMenuContainer/Collection_Button
@onready var deck_btn   := $HBoxContainer/SubMenuContainer/DeckEditor_Button
@onready var play_btn   := $HBoxContainer/SubMenuContainer/PlayButton
@onready var p1p2_btn   := $HBoxContainer/SubMenuContainer/P1vsP2_Button
@onready var vscomp_btn := $HBoxContainer/SubMenuContainer/VSComputer_Button

var current_mode: String = "story"

func _ready() -> void:
	story_btn.pressed.connect(_on_story)
	casual_btn.pressed.connect(_on_casual)
	ranked_btn.pressed.connect(_on_ranked)
	settings_btn.pressed.connect(_on_settings)
	profile_btn.pressed.connect(_on_profile)
	quit_btn.pressed.connect(_on_quit)

	shop_btn.pressed.connect(_on_shop)
	coll_btn.pressed.connect(_on_collection)
	deck_btn.pressed.connect(_on_deckselect)
	play_btn.pressed.connect(_on_play)
	back_btn.pressed.connect(_on_back)
	p1p2_btn.pressed.connect(_on_p1p2)
	vscomp_btn.pressed.connect(_on_vscomp)

	update_mode_ui()
	sub_menu.visible = false
	$HBoxContainer/Menu.visible = true

func update_mode_ui() -> void:
	if Globals.is_offline:
		mode_lbl.text = "Mode: Offline (Story Only)"
		profile_btn.disabled = true
		ranked_btn.disabled = true
	else:
		mode_lbl.text = "Mode: %s" % current_mode.capitalize()
		profile_btn.disabled = false
		ranked_btn.disabled = false

func _on_story() -> void:
	current_mode = "story"
	show_sub()

func _on_casual() -> void:
	current_mode = "casual"
	show_sub()

func _on_ranked() -> void:
	if Globals.is_offline:
		push_warning("Ranked disabled offline")
	else:
		current_mode = "ranked"
		show_sub()

func show_sub() -> void:
	sub_menu.visible = true
	$HBoxContainer/Menu.visible = false

func _on_back() -> void:
	sub_menu.visible = false
	$HBoxContainer/Menu.visible = true

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")

func _on_profile() -> void:
	if not Globals.is_offline:
		get_tree().change_scene_to_file("res://UI/ProfilePage.tscn")

func _on_quit() -> void:
	get_tree().quit()

func _on_shop() -> void:
	get_tree().change_scene_to_file("res://UI/Shop_%s.tscn" % current_mode.capitalize())

func _on_collection() -> void:
	get_tree().change_scene_to_file("res://UI/CardCollection_%s.tscn" % current_mode.capitalize())

func _on_deckselect() -> void:
	# Deck selector is the same for all modes
	get_tree().change_scene_to_file("res://Scenes/DeckEditor/DeckSelector.tscn")

func _on_play() -> void:
	get_tree().change_scene_to_file("res://Battle/GameBoard_%s.tscn" % current_mode.capitalize())

func _on_p1p2() -> void:
	get_tree().change_scene_to_file("res://Battle/P1vsP2.tscn")

func _on_vscomp() -> void:
	get_tree().change_scene_to_file("res://Battle/VS_Computer.tscn")
