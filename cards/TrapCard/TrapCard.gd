extends BaseCard
class_name TrapCard

@export var trigger_condition: String = ""
@export var trap_effect: Dictionary = {}

func initialize_card(data: Dictionary) -> void:
	super.initialize_card(data)
	trigger_condition = data.get("trigger_condition", "")
	trap_effect = data.get("trap_effect", {})

func check_trigger(trigger: String) -> void:
	if trigger == trigger_condition:
		apply_effect()

func apply_effect() -> void:
	if trap_effect.has("effect") and trap_effect["effect"].has_method("apply"):
		trap_effect["effect"].apply(self)
		print(card_name, "trap triggered")
