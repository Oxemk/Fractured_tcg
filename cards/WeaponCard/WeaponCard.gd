extends BaseCard
class_name WeaponCard

@export var attack: int = 5

func initialize_card(data: Dictionary) -> void:
	super.initialize_card(data)
	attack = data.get("attack", attack)

	var atk_lbl = get_node_or_null("HBoxContainer/Attack")
	if atk_lbl:
		atk_lbl.text = str(attack)
	else:
		push_error("WeaponCard: 'Attack' label not found!")
