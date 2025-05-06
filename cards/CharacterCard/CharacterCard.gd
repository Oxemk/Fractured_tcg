extends BaseCard
class_name CharacterCard

@export var health: int = 100
@export var defense: int = 10

func initialize_card(data: Dictionary) -> void:
	super.initialize_card(data)

	health = data.get("health", health)
	defense = data.get("defense", defense)

	var h_lbl = get_node_or_null("CanvasLayer/Health")
	if h_lbl:
		h_lbl.text = str(health)
	else:
		push_error("CharacterCard: 'Health' not found!")

	var d_lbl = get_node_or_null("CanvasLayer/Defense")
	if d_lbl:
		d_lbl.text = str(defense)
	else:
		push_error("CharacterCard: 'Defense' not found!")

	var lvl_lbl = get_node_or_null("CanvasLayer/Level")
	if lvl_lbl:
		lvl_lbl.text = "Lvl %d" % level
	else:
		push_error("CharacterCard: 'Level' not found!")

func apply_damage(damage: int) -> void:
	var remaining = damage
	if defense > 0:
		var absorbed = min(defense, remaining)
		defense -= absorbed
		remaining -= absorbed
	if remaining > 0:
		health -= remaining
	if health <= 0:
		queue_free()
	print(card_name, "DEF:", defense, "HP:", health)
