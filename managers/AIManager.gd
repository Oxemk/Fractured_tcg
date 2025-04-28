extends Node

var easy_pool = []
var medium_pool = []
var hard_pool = []
var card_data = {}
const MODE_SIZES = {"duelist":20,"bodyguard":30,"commander":40}

func _ready():
	randomize()
	card_data = DataUtils.load_data("res://data/card_database.json").get("cards", {})
	prepare_pools()

func prepare_pools():
	for cid in card_data.keys():
		var r = card_data[cid].get("rarity", "common").to_lower()
		match r:
			"common": easy_pool.append(cid)
			"uncommon": medium_pool.append(cid)
			_: hard_pool.append(cid)

func get_deck(diff: String, mode: String) -> Array:
	var pool: Array
	match diff.to_lower():
		"easy": pool = easy_pool.duplicate()
		"medium": pool = (easy_pool + medium_pool).duplicate()
		"hard": pool = (easy_pool + medium_pool + hard_pool).duplicate()
		_: return []
	pool.shuffle()
	return pool.slice(0, min(MODE_SIZES.get(mode.to_lower(),20), pool.size()))
