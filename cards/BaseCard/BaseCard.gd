extends Control
class_name BaseCard

# --- Signals ---
signal pressed

# --- Common Exports ---
@export var card_name: String = "Unnamed"
@export var card_type: String = "Unknown"
@export var race: String = "none"
@export var description: String = ""
@export var level: int = 1
@export var image_path: String = "res://assets/Images/placeholder.png"
@export var special_ability: String = "None"
@export var attack_move: Dictionary = {}
@export var cooldown: int = 0
@export var effect: String = "none"
@export var health: int = 10
@export var max_health: int = 10
@export var defense: int = 10
@export var max_defense: int = 10

# --- Class Specific ---
@export var class_type: String = ""
@export var class_ability: String = ""

# --- Field Specific ---
@export var field_effect: Dictionary = {}

# --- Support Specific ---
@export var support_benefit: Dictionary = {}

# --- Trap Specific ---
@export var trigger_condition: String = ""
@export var trap_effect: Dictionary = {}

# --- Weapon Specific ---
@export var attack: int = 5

# --- Selectable ---
var is_selectable: bool = false

# --- Effect Support ---
const EffectDataResource = preload("res://managers/EffectData.gd")
const EffectType = preload("res://managers/EffectTypes.gd").EffectType

var card_data: Dictionary = {}
var active_effects: Array = []

func _ready():
	update_ui()

func initialize_card(data: Dictionary) -> void:
	card_data = data
	card_name = data.get("name", card_name)
	card_type = data.get("card_type", card_type)
	race = data.get("race", race)
	description = data.get("description", description)
	level = data.get("level", level)
	image_path = data.get("image_path", image_path)
	special_ability = data.get("special_ability", special_ability)
	attack_move = data.get("attack_move", attack_move)
	cooldown = data.get("cooldown", cooldown)
	effect = data.get("effect", effect)
	health = data.get("health", health)
	max_health = data.get("max_health", max_health)
	defense = data.get("defense", defense)
	max_defense = data.get("max_defense", max_defense)
	attack = data.get("attack", attack)
	class_type = data.get("class_type", class_type)
	class_ability = data.get("class_ability", class_ability)
	field_effect = data.get("field_effect", field_effect)
	support_benefit = data.get("support_benefit", support_benefit)
	trigger_condition = data.get("trigger_condition", trigger_condition)
	trap_effect = data.get("trap_effect", trap_effect)
	update_ui()

func update_ui() -> void:
	var h_lbl = get_node_or_null("CanvasLayer/health") as Label
	if h_lbl:
		h_lbl.text = "%d/%d" % [health, max_health]
	var d_lbl = get_node_or_null("CanvasLayer/defense") as Label
	if d_lbl:
		d_lbl.text = "%d/%d" % [defense, max_defense]
	var lvl_lbl = get_node_or_null("CanvasLayer/level") as Label
	if lvl_lbl:
		lvl_lbl.text = "Lvl %d" % level
	var cool_lbl = get_node_or_null("CanvasLayer/HBoxContainer/cooldown") as Label
	if cool_lbl:
		cool_lbl.text = "%d" % cooldown
	var atm_lbl = get_node_or_null("CanvasLayer/HBoxContainer/attack_move") as Label
	if atm_lbl:
		atm_lbl.text = str(attack_move.get("name", ""))
	var rac_lbl = get_node_or_null("CanvasLayer/race") as Label
	if rac_lbl:
		rac_lbl.text = race.capitalize()
	var dec_lbl = get_node_or_null("CanvasLayer/description") as Label
	if dec_lbl:
		dec_lbl.text = description
	var name_lbl = get_node_or_null("CanvasLayer/card_name") as Label
	if name_lbl:
		name_lbl.text = card_name.capitalize()
	var atk_lbl = get_node_or_null("CanvasLayer/HBoxContainer/attack") as Label
	if atk_lbl:
		atk_lbl.text = str(attack)
	var type_lbl = get_node_or_null("CanvasLayer/ClassType") as Label
	if type_lbl:
		type_lbl.text = class_type.capitalize()
	var abil_lbl = get_node_or_null("CanvasLayer/ClassAbility") as Label
	if abil_lbl:
		abil_lbl.text = class_ability
	var art = get_node_or_null("CanvasLayer/image_path") as TextureRect
	if art and image_path:
		var img = load(image_path)
		if img:
			art.texture = img

func set_selectable(enable: bool) -> void:
	is_selectable = enable
	# Visual feedback (glow, modulate, etc.)
	modulate = Color(1, 1, 1) if enable else Color(0.7, 0.7, 0.7)

func _gui_input(event):
	if is_selectable and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("pressed")

func apply_damage(amount: int) -> void:
	var spill = max(amount - defense, 0)
	defense = max(defense - amount, 0)
	health = max(health - spill, 0)
	update_ui()

func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	update_ui()

func add_effect_duration(effect_type: int, value: int, duration: int) -> void:
	var e = EffectDataResource.new(effect_type, value, duration)
	active_effects.append(e)

func update_effects() -> void:
	for e in active_effects.duplicate():
		if e.type == EffectType.POISON:
			apply_damage(e.value)
		e.duration -= 1
		if e.duration <= 0:
			active_effects.erase(e)
	update_ui()

func repair_armor(amount: int) -> void:
	defense = min(defense + amount, max_defense)
	print(card_name, "repaired", amount)

func use_support(target: Node) -> void:
	var benefit_type = support_benefit.get("type", "")
	var amount = support_benefit.get("amount", 0)
	if benefit_type == "healing" and target.has("health"):
		target.health = min(target.health + amount, target.max_health)
	elif benefit_type == "repair" and target.has("defense"):
		target.defense = min(target.defense + amount, target.max_defense)
	print(card_name, "used", benefit_type, amount)

func apply_field_effect() -> void:
	if field_effect.get("effect", null) and field_effect["effect"].has_method("apply"):
		field_effect["effect"].apply(self)
		print(card_name, "field effect applied")

func check_trigger(trigger: String) -> void:
	if trigger == trigger_condition:
		apply_trap_effect()

func apply_trap_effect() -> void:
	if trap_effect.get("type", "") == "damage":
		apply_damage(trap_effect.get("amount", 0))
	elif trap_effect.get("type", "") == "heal":
		heal(trap_effect.get("amount", 0))
	if trap_effect.get("effect", null) and trap_effect["effect"].has_method("apply"):
		trap_effect["effect"].apply(self)
	print(card_name, "trap effect applied")

func _input(event):
	CardDragManager.handle_card_input(self, event)
