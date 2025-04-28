extends BaseCard
class_name SupportCard

@export var support_benefit: Dictionary = {}



func initialize_card(data: Dictionary) -> void:

	# Optional: Update visuals using data values here
	super.initialize_card(data)
	support_benefit = data.get("support_benefit",{})

func use_support(target: Node) -> void:
	var t = support_benefit.get("type","")
	var a = support_benefit.get("amount",0)
	if t == "healing":
		target.health += a
	elif t == "repair":
		target.defense += a
	print(card_name, "used", t, a)
