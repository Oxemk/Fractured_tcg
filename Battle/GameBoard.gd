extends Node
class_name GameBoard

@onready var PlayerBoard = $PlayerBoard
@onready var EnemyBoard  = $EnemyBoard
@onready var PlayerHand  = $PlayerHand  # NEW: Control node for hand display

var config: Dictionary
var player_instances: Array = []
var ai_instances: Array     = []
	
func _ready() -> void:
	# Grab the deck config set earlier (deck name, mode, ai_difficulty, etc.)
	config = Globals.selected_deck
	# Instantiate player cards
	for cid in config.cards:
		var card = CardLoader.load_card_data(_load_card_json(cid))
		PlayerBoard.add_child(card)
		player_instances.append(card)
	# Instantiate AI cards if configured
	if config.has("ai_difficulty"):
		var ai_ids = AiManager.get_deck(config.ai_difficulty, config.mode)

		for cid in ai_ids:
			var card = CardLoader.load_card_data(_load_card_json(cid))
			EnemyBoard.add_child(card)
			ai_instances.append(card)
	# Kick off the first phase
	_startup_phase()

# Helper to load the JSON dictionary for a given card ID
func _load_card_json(card_id: String) -> Dictionary:
	var all = DataUtils.load_data("res://cards/Data/card_database.json").get("cards", {})
	return all.get(card_id, {})

func _startup_phase() -> void:
	var phase = preload("res://phases/StartupPhase.gd").new()
	add_child(phase)
	phase.start_phase(self)

func switch_to_turn() -> void:
	var phase = preload("res://phases/TurnPhase.gd").new()
	add_child(phase)
	phase.start_phase(self)

func switch_to_victory() -> void:
	var phase = preload("res://phases/VictoryPhase.gd").new()
	add_child(phase)
	phase.start_phase(self)

func check_victory() -> bool:
	# Example: victory when one side has no CharacterCards left
	return PlayerBoard.get_child_count() == 0 or EnemyBoard.get_child_count() == 0

func display_victory() -> void:
	# Simply go back to MainMenu (or show a popup)
	get_tree().change_scene_to_file("res://main/MainMenu.tscn")
