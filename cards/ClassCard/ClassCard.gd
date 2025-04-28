extends BaseCard
class_name ClassCard

@export var class_type: String = ""
@export var class_ability: String = ""



func initialize_card(data: Dictionary) -> void:
	
	# Optional: Update visuals using data values here
	super.initialize_card(data)
	class_type    = data.get("class_type","")
	class_ability = data.get("class_ability","")

func perform_class_ability() -> void:
	print("Class ability: %s" % class_ability)
