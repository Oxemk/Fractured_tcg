extends Control
class_name BaseCard

# --- Common Exports ---
@export var card_name = "Unnamed"
@export var card_type = "Unknown"
@export var race = "none"
@export var description = ""
@export var level = 1
@export var image_path = "res://assets/Images/placeholder.png"
@export var special_ability = "None"
@export var attack_move: Dictionary = {}
@export var cooldown = 0
@export var effect = "none"
@export var health = 10
@export var max_health = 10
@export var defense = 0

# --- Class Specific Exports ---
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

const EffectDataResource = preload("res://managers/EffectData.gd")
const EffectType = preload("res://managers/EffectTypes.gd").EffectType

var card_data = {}
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
	max_health = data.get("health", max_health)
	defense = data.get("defense", defense)
	attack = data.get("attack", attack)
	class_type = data.get("class_type", class_type)
	class_ability = data.get("class_ability", class_ability)
	field_effect = data.get("field_effect", field_effect)
	support_benefit = data.get("support_benefit", support_benefit)
	trigger_condition = data.get("trigger_condition", trigger_condition)
	trap_effect = data.get("trap_effect", trap_effect)

	update_ui()

func update_ui() -> void:
	var h_lbl = get_node_or_null("CanvasLayer/HealthLabel") as Label
	if h_lbl:
		h_lbl.text = "%d/%d" % [health, max_health]

	var d_lbl = get_node_or_null("CanvasLayer/DefenseLabel") as Label
	if d_lbl:
		d_lbl.text = str(defense)

	var lvl_lbl = get_node_or_null("CanvasLayer/LevelLabel") as Label
	if lvl_lbl:
		lvl_lbl.text = "Lvl %d" % level

	var atk_lbl = get_node_or_null("HBoxContainer/Attack")
	if atk_lbl:
		atk_lbl.text = str(attack)

	var type_lbl = get_node_or_null("CanvasLayer/ClassType")
	if type_lbl:
		type_lbl.text = class_type.capitalize()

	var abil_lbl = get_node_or_null("CanvasLayer/ClassAbility")
	if abil_lbl:
		abil_lbl.text = class_ability

	var def_lbl = get_node_or_null("CanvasLayer/Defense")
	if def_lbl:
		def_lbl.text = str(defense)

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
		match e.type:
			EffectType.POISON:
				apply_damage(e.value)
		e.duration -= 1
		if e.duration <= 0:
			active_effects.erase(e)
	update_ui()

func repair_armor(amount: int) -> void:
	defense += amount
	print(card_name, "repaired", amount)

func use_support(target: Node) -> void:
	var benefit_type = support_benefit.get("type", "")
	var amount = support_benefit.get("amount", 0)
	if benefit_type == "healing" and target.has_variable("health"):
		target.health += amount
	elif benefit_type == "repair" and target.has_variable("defense"):
		target.defense += amount
	print(card_name, "used", benefit_type, amount)

func apply_field_effect() -> void:
	if field_effect.has("effect") and field_effect["effect"].has_method("apply"):
		field_effect["effect"].apply(self)
		print(card_name, "field effect applied")

func check_trigger(trigger: String) -> void:
	if trigger == trigger_condition:
		apply_trap_effect()

func apply_trap_effect() -> void:
	if trap_effect.has("effect") and trap_effect["effect"].has_method("apply"):
		trap_effect["effect"].apply(self)
		print(card_name, "trap triggered")
