extends BaseCard
class_name FieldCard

@export var field_effect: Dictionary = {}

func initialize_card(data: Dictionary) -> void:
	super.initialize_card(data)
	field_effect = data.get("field_effect", {})

func apply_field_effect() -> void:
	if field_effect.has("effect") and field_effect["effect"].has_method("apply"):
		field_effect["effect"].apply(self)
		print(card_name, "field effect applied")
