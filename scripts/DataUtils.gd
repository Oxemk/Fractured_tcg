extends Node

static func save_data(path: String, data: Variant) -> void:
	var f = FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()

static func load_data(path: String) -> Dictionary:
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		return {}
	var res = JSON.parse_string(f.get_as_text())
	f.close()
	return res if typeof(res) == TYPE_DICTIONARY else {}
static func get_decks_by_mode(path: String, mode: String) -> Array:
	var data = load_data(path)
	var decks = data.get("decks", [])
	
	if typeof(decks) != TYPE_ARRAY:
		return []
	
	return decks.filter(func(deck):
		return typeof(deck) == TYPE_DICTIONARY and deck.get("mode", "") == mode)
