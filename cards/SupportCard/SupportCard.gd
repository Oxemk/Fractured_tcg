extends BaseCard
class_name SupportCard

@export var support_benefit: Dictionary = {}

func initialize_card(data: Dictionary) -> void:
	super.initialize_card(data)
	support_benefit = data.get("support_benefit", {})

func use_support(target: Node) -> void:
	var benefit_type = support_benefit.get("type", "")
	var amount = support_benefit.get("amount", 0)
	if benefit_type == "healing" and target.has_variable("health"):
		target.health += amount
	elif benefit_type == "repair" and target.has_variable("defense"):
		target.defense += amount
	print(card_name, "used", benefit_type, amount)
