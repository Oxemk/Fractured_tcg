extends BaseCard
class_name ClassCard

@export var class_type: String    = ""
@export var class_ability: String = ""

func initialize_card(data: Dictionary) -> void:
	super.initialize_card(data)
	class_type    = data.get("class_type", class_type)
	class_ability = data.get("class_ability", class_ability)

	# Optionally update UI
	var type_lbl = get_node_or_null("CanvasLayer/ClassType")
	if type_lbl:
		type_lbl.text = class_type.capitalize()

	var abil_lbl = get_node_or_null("CanvasLayer/ClassAbility")
	if abil_lbl:
		abil_lbl.text = class_ability 
