extends Node

var easy_pool: Array = []
var medium_pool: Array = []
var hard_pool: Array = []
var card_data: Dictionary = {}

const MODE_SIZES = {
	"duelist": 20,
	"bodyguard": 30,
	"commander": 40
}

func _ready() -> void:
	randomize()
	card_data = DataUtils.load_data("res://data/card_database.json").get("cards", {})
	_prepare_pools()

func _prepare_pools() -> void:
	easy_pool.clear()
	medium_pool.clear()
	hard_pool.clear()

	for cid in card_data.keys():
		var r = card_data[cid].get("rarity", "common").to_lower()
		match r:
			"common":
				easy_pool.append(cid)
			"uncommon":
				medium_pool.append(cid)
			_:
				hard_pool.append(cid)

func get_deck(diff: String, mode: String) -> Array:
	var pool: Array
	match diff.to_lower():
		"easy":
			pool = easy_pool.duplicate()
		"medium":
			pool = (easy_pool + medium_pool).duplicate()
		"hard":
			pool = (easy_pool + medium_pool + hard_pool).duplicate()
		_:
			return []

	pool.shuffle()
	var size = MODE_SIZES.get(mode.to_lower(), 20)
	return pool.slice(0, min(size, pool.size()))
