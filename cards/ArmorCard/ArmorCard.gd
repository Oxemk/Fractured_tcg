extends BaseCard
class_name ArmorCard

@export var defense: int = 20

func initialize_card(data: Dictionary) -> void:
	# Optional: Update visuals using data values here
	super.initialize_card(data)
	defense = data.get("defense",20)
	$Defense.text = str(defense)

func repair_armor(a:int) -> void:
	defense += a
	print(card_name, "repaired", a)
