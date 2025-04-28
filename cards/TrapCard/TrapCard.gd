extends BaseCard
class_name TrapCard

@export var trigger_condition: String = ""
@export var trap_effect: Dictionary = {}



func initialize_card(data: Dictionary) -> void:
	card_data = data
	# Optional: Update visuals using data values here
	super.initialize_card(data)
	trigger_condition = data.get("trigger_condition","")
	trap_effect = data.get("trap_effect",{})

func check_trigger(t:String) -> void:
	if t == trigger_condition:
		apply_effect()

func apply_effect() -> void:
	if trap_effect.has("effect"):
		trap_effect["effect"].apply(self)
		print(card_name, "trap triggered")
