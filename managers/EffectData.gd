extends Resource
class_name EffectData

@export var type: int
@export var value: int
@export var duration: int

func _init(_type: int = 0, _value: int = 0, _duration: int = 0) -> void:
	type = _type
	value = _value
	duration = _duration
