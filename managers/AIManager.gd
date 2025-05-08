extends Node

var card_data: Dictionary = {}
var easy_pool: Array = []
var medium_pool: Array = []
var hard_pool: Array = []

# Function to safely load data from JSON file
func load_data(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data = {}
	if file:
		var file_contents = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(file_contents)
		if parse_result == OK:
			data = json.get_data()
		else:
			print("Error parsing JSON: %s" % parse_result)
		file.close()
	else:
		print("Error opening file: %s" % file_path)
		return {}  # Return an empty dictionary if the file can't be opened

	return data

# Function to prepare card pools based on rarity and category
func _prepare_pools() -> void:
	# Clear existing pools to prevent old data from interfering
	easy_pool.clear()
	medium_pool.clear()
	hard_pool.clear()

	# Categories to loop through
	var categories = ["Character", "Class", "Weapon", "Armor", "Field", "Trap", "Support"]
	
	# Iterate over each category to populate the pools
	for category in categories:
		if card_data.has(category):
			var cards = card_data[category]
			for card in cards:
				# Safety checks for missing fields
				if not card.has("id") or not card.has("rarity"):
					print("Skipping card due to missing required fields: %s" % card)
					continue

				# Get the rarity field and assign cards to the correct pool
				var rarity = card.get("rarity", "Unknown")
				if rarity == "Common":
					easy_pool.append(card["id"])
				elif rarity == "Uncommon":
					medium_pool.append(card["id"])
				elif rarity == "Rare" or rarity == "Epic":
					hard_pool.append(card["id"])
				else:
					print("Unknown rarity for card '%s'. Skipping card." % card["name"])

	# Debugging: Print pool sizes after population
	print("Easy Pool: %d cards" % easy_pool.size())  # Print pool sizes
	print("Medium Pool: %d cards" % medium_pool.size())
	print("Hard Pool: %d cards" % hard_pool.size())
	print("Pool sizes => Easy: %d, Medium: %d, Hard: %d" % [
		easy_pool.size(), medium_pool.size(), hard_pool.size()
	])

# Initialize card data and prepare pools
func _ready() -> void:
	# Randomize and load the data
	randomize()
	card_data = load_data("res://data/card_database.json").get("cards", {})
	if card_data.is_empty():
		print("Card data is empty. Exiting...")
		return  # Exit early if data is empty, to prevent further issues

	print("Loaded Card Data: %s" % card_data)  # Debugging: Check data
	_prepare_pools()

# Function to generate a deck based on difficulty and mode
func generate_deck(diff: String, mode: String) -> Array:
	# Ensure there are enough cards in the pools
	if diff == "easy" and easy_pool.size() > 0:
		var deck = generate_deck_from_pool(easy_pool)
		print("Generated easy deck: %s" % deck)
		return deck
	elif diff == "medium" and medium_pool.size() > 0:
		var deck = generate_deck_from_pool(medium_pool)
		print("Generated medium deck: %s" % deck)
		return deck
	elif diff == "hard" and hard_pool.size() > 0:
		var deck = generate_deck_from_pool(hard_pool)
		print("Generated hard deck: %s" % deck)
		return deck
	else:
		print("Not enough cards in pool for difficulty: %s" % diff)
		return []  # Return an empty deck if there are no cards for the difficulty

# Helper function to generate a deck from the given pool
func generate_deck_from_pool(pool: Array) -> Array:
	var deck = []
	var card_limit = 20  # Max cards per deck

	# Randomly select cards for the deck
	for i in range(min(pool.size(), card_limit)):
		var card_id = pool[randi() % pool.size()]
		deck.append(card_id)

	return deck
