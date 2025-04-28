extends Control
class_name LoginUI

@onready var user_fld := $User/USERNAME
@onready var pass_fld := $Password/Password
@onready var btn_login := $LogandReg/Login
@onready var btn_reg   := $LogandReg/Register
@onready var btn_off   := $LogandReg/Offline

func _ready() -> void:
	btn_login.pressed.connect(_on_login)
	btn_reg.pressed.connect(_on_register)
	btn_off.pressed.connect(_on_offline)

func _on_login() -> void:
	if UserManager.login_user(user_fld.text.strip_edges(), pass_fld.text.strip_edges()):
		get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func _on_register() -> void:
	UserManager.register_user(user_fld.text.strip_edges(), pass_fld.text.strip_edges())

func _on_offline() -> void:
	Globals.is_offline = true
	UserManager.load_offline_user()
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
