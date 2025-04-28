extends Node


var users: Dictionary = {}
var current_user: Dictionary = {}

func _ready():
	load_users()

func load_users() -> void:
	users = DataUtils.load_data("user://users.json")

func save_users() -> void:
	DataUtils.save_data("user://users.json", users)

func register_user(username: String, password: String) -> bool:
	if username in users:
		return false
	users[username] = {
		"password": password,
		"bp": 0,
		"cards": [],
		"decks": {"story": [], "casual": [], "ranked": []}
	}
	save_users()
	return true

func login_user(username: String, password: String) -> bool:
	if username in users and users[username]["password"] == password:
		current_user = users[username]
		return true
	return false

func load_offline_user() -> void:
	var offline = "OfflinePlayer"
	if not (offline in users):
		users[offline] = {
			"password": "",
			"bp": 0,
			"cards": [],
			"decks": {"story": [], "casual": [], "ranked": []}
		}
		save_users()
	current_user = users[offline]
	Globals.is_offline = true
