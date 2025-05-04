extends Control

@onready var thumbnail: TextureButton = $Thumbnail
@onready var name_label: Label = $NameLabel
@onready var type_label: Label = $TypeLabel
@onready var level_label: Label = $LevelLabel
@onready var base_hp_label: Label = $BaseHPLabel     # New: Base HP label
@onready var defense_label: Label = $DefenseLabel    # New: Defense label

var card_id: String

func setup(card_data: Dictionary) -> void:
	card_id = card_data.get("id", "")
	name_label.text = card_data.get("name", card_id)
	type_label.text = card_data.get("type", "Unknown")

	# Display Level
	var level = card_data.get("level", -1)
	level_label.text = level >= 0 ? "Level %d" % level : ""

	# Display Base HP
	var base_hp = card_data.get("base_hp", 0)
	base_hp_label.text = "HP: %d" % base_hp

	# Display Defense
	var defense = card_data.get("defense", 0)
	defense_label.text = "Def: %d" % defense

	# Thumbnail display
	var tex_path = card_data.get("thumbnail_path", "")
	if tex_path != "" and ResourceLoader.exists(tex_path):
		thumbnail.texture_normal = load(tex_path)
	else:
		thumbnail.texture_normal = preload("res://UI/FallbackCard.png")
