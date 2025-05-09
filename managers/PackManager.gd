extends Node

@export var pack_data_path: String = "res://packs/pack.json"
var packs: Dictionary = {}

func _ready():
	var data = DataUtils.load_data(pack_data_path)
	if typeof(data) == TYPE_DICTIONARY and data.has("packs"):
		packs = data["packs"]
	else:
		packs = {}  # fallback if load failed or no "packs" key

func open_pack(pack_id: String) -> Array:
	var entry = {}
	if packs.has(pack_id) and typeof(packs[pack_id]) == TYPE_DICTIONARY:
		entry = packs[pack_id]
	# get cards list or empty Array
	var list = entry.get("cards", [])
	var out: Array = []
	for pack_def in list:
		var id = pack_def.get("id", "")
		var cnt = pack_def.get("count", 0)
		for i in cnt:
			out.append(id)
	return out
