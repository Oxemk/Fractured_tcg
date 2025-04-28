extends BaseCard
class_name WeaponCard

@export var attack: int = 5



func initialize_card(data: Dictionary) -> void:

	# Optional: Update visuals using data values here
	super.initialize_card(data)
	attack = data.get("attack",5)
	$Attack.text = str(attack)

func apply_damage(d:int) -> void:
	print(card_name, "weapon deals", d)
