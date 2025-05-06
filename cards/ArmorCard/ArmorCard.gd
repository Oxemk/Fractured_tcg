extends BaseCard
class_name ArmorCard

@export var defense: int = 20

func initialize_card(data: Dictionary) -> void:
	super.initialize_card(data)
	defense = data.get("defense", defense)

	var def_lbl = get_node_or_null("CanvasLayer/Defense")
	if def_lbl:
		def_lbl.text = str(defense)
	else:
		push_error("ArmorCard: 'Defense' label not found!")

func repair_armor(amount: int) -> void:
	defense += amount
	print(card_name, "repaired", amount)
