extends BaseCard
class_name CharacterCard

@export var health: int = 100
@export var defense: int = 10



func initialize_card(data: Dictionary) -> void:

	# Optional: Update visuals using data values here
	super.initialize_card(data)
	health = data.get("health",100)
	defense = data.get("defense",10)
	$Health.text = str(health)
	$Defense.text = str(defense)
	$Level.text = "Lvl %d" % level

func apply_damage(d:int) -> void:
	var rem = d
	if defense>0:
		var d1 = min(defense,rem)
		defense -= d1; rem -= d1
	if rem>0:
		health -= rem
	if health<=0:
		queue_free()
	print(card_name, "DEF:", defense, "HP:", health)
