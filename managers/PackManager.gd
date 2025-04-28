extends Node


@export var pack_data_path: String = "res://packs/pack.json"
var packs: Dictionary = {}

func _ready():
	packs = DataUtils.load_data(pack_data_path).get("packs", {})

func open_pack(pack_id: String) -> Array:
	var list = packs.get(pack_id, {}).get("cards", [])
	var out: Array = []
	for entry in list:
		for i in range(entry["count"]):
			out.append(entry["id"])
	return out
