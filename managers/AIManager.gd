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

@export var random_decks: Array = []
@export var filtered_user_decks: Array = []
@export var filtered_ai_decks: Array = []

@export var p1_container: OptionButton
@export var p2_container: OptionButton

func _ready() -> void:
	randomize()

	card_data = DataUtils.load_data("res://data/card_database.json").get("cards", {})
	if card_data.size() == 0:
		push_warning("Card data is empty. Deck generation will fail.")
		return

	_prepare_pools()

	if p1_container:
		p1_container.connect("item_selected", Callable(self, "_on_p1_item_selected"))
	if p2_container:
		p2_container.connect("item_selected", Callable(self, "_on_p2_item_selected"))


func _prepare_pools() -> void:
	easy_pool.clear()
	medium_pool.clear()
	hard_pool.clear()

	for cid in card_data.keys():
		var rarity = card_data[cid].get("rarity", "common").to_lower()
		match rarity:
			"common":
				easy_pool.append(cid)
			"uncommon":
				medium_pool.append(cid)
			_:
				hard_pool.append(cid)

	print("Pools prepared: Easy=%d, Medium=%d, Hard=%d" % [
		easy_pool.size(), medium_pool.size(), hard_pool.size()])


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
			print("Invalid difficulty requested: %s" % diff)
			return []

	pool.shuffle()
	var size = MODE_SIZES.get(mode.to_lower(), 20)
	return pool.slice(0, min(size, pool.size()))


func _populate_buttons() -> void:
	if not p1_container or not p2_container:
		print("Warning: UI containers not assigned.")
		return

	p1_container.clear()
	p2_container.clear()

	var all_decks = random_decks + filtered_user_decks + filtered_ai_decks
	var count_rng = random_decks.size()
	var count_user = filtered_user_decks.size()

	for i in range(all_decks.size()):
		var d = all_decks[i]
		var prefix = "RNG" if d.has("random") else ("P" if i < count_rng + count_user else "AI")
		var deck_name = d.get("name", "Unnamed Deck")

		p1_container.add_item("[%s] %s" % [prefix, deck_name])
		p2_container.add_item("[%s] %s" % [prefix, deck_name])

		p1_container.set_item_metadata(p1_container.get_item_count() - 1, i)
		p2_container.set_item_metadata(p2_container.get_item_count() - 1, i)

	print("Deck buttons populated.")


func _on_p1_item_selected(index: int) -> void:
	var deck_index = p1_container.get_item_metadata(index)
	print("Player 1 selected deck index: %d" % deck_index)
	# Your deck selection logic here


func _on_p2_item_selected(index: int) -> void:
	var deck_index = p2_container.get_item_metadata(index)
	print("Player 2 selected deck index: %d" % deck_index)
	# Your deck selection logic here
