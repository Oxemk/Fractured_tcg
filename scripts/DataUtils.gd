extends Node

static func save_data(path: String, data: Variant) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

static func load_data(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
	var text = file.get_as_text()
	file.close()

	var parser = JSON.new()
	var err = parser.parse(text)
	if err != OK:
		push_warning("JSON parse error (%d) in %s: %s" % [err, path, parser.error_string])
		return null

	return parser.get_data()

static func get_decks_by_mode(path: String, mode: String) -> Array:
	var data = load_data(path)
	# Ensure we got a Dictionary back
	if typeof(data) != TYPE_DICTIONARY:
		return []

	var decks = data.get("decks", [])
	# Ensure decks is an Array
	if typeof(decks) != TYPE_ARRAY:
		return []

	var out: Array = []
	for deck in decks:
		if typeof(deck) == TYPE_DICTIONARY and deck.get("mode", "") == mode:
			out.append(deck)
	return out
