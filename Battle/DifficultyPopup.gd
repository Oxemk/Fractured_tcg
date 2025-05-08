extends Window
class_name DifficultyPopup

signal difficulty_selected(level: String)
var easy_btn: Button
var medium_btn: Button
var hard_btn: Button

func _ready():
	easy_btn = get_node("VBoxContainer/Easy")
	medium_btn = get_node("VBoxContainer/Medium")
	hard_btn = get_node("VBoxContainer/Hard")

	easy_btn.connect("pressed", Callable(self, "_on_difficulty_pressed").bind("easy"))
	medium_btn.connect("pressed", Callable(self, "_on_difficulty_pressed").bind("medium"))
	hard_btn.connect("pressed", Callable(self, "_on_difficulty_pressed").bind("hard"))
func _on_difficulty_pressed(level: String) -> void:
	emit_signal("difficulty_selected", level)
	hide()
