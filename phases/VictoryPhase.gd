extends Node
class_name VictoryPhases

var gameboard : Node

# Start the Victory Phase
func start_phase(gameboard_instance: Node) -> void:
	gameboard = gameboard_instance  # Assign the passed gameboard instance to the class variable
	
	# 1) Check if the Deckmaster is still on the board for both Player and AI
	var player_deckmaster = _get_deckmaster(gameboard.PlayerBoard)
	var ai_deckmaster = _get_deckmaster(gameboard.EnemyBoard)
	
	# 2) Determine the winner
	if not player_deckmaster and ai_deckmaster:
		_display_victory("AI Wins! Player's Deckmaster was defeated.")
	elif not ai_deckmaster and player_deckmaster:
		_display_victory("Player Wins! AI's Deckmaster was defeated.")
	elif not player_deckmaster and not ai_deckmaster:
		_display_victory("It's a Draw! No Deckmasters remain.")
	else:
		print("Unexpected state: Both players still have Deckmasters.")
		# If both players still have Deckmasters, continue the game (or handle other logic)
		_transition_to_turn_phase()

# Helper function to get the Deckmaster card from a board
func _get_deckmaster(board: Node) -> Node:
	for card in board.get_children():
		if card.has_method("get_role") and card.get_role() == "deckmaster":
			return card
	return null

# Display the victory screen and message
func _display_victory(winner_message: String) -> void:
	print(winner_message)  # For debugging, in a real game you could display a UI screen.
	
	# Example: Show victory screen on the GameBoard UI
	gameboard.show_victory_screen(winner_message)

	# Optionally, disable further game input or transition to a game-over state
	gameboard.end_game()  # This could be a function to disable the game or show a final screen
	
	# Here you could also reset the game, give players the option to restart, etc.
	# For example:
	# gameboard.restart_game()

# Transition back to Turn Phase if needed (e.g., for rematch, new round, or game restart)
func _transition_to_turn_phase() -> void:
	var turn_phase = preload("res://phases/TurnPhase.gd").new()  # Load the Turn Phase scene
	gameboard._switch_to_phase(turn_phase)  # Switch to the Turn Phase
