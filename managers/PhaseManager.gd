extends Node

var gameboard: Node = null
var phase_queue: Array = []
var current_phase: Node = null

# Initialize PhaseManager with the gameboard
func init(board: Node) -> void:
	gameboard = board
	phase_queue.clear()
	enqueue_standard_cycle()
	start_next_phase()

# Enqueue standard phases in the cycle
func enqueue_standard_cycle() -> void:
	phase_queue = [
		preload("res://phases/DrawPhase.gd").new(),
		preload("res://phases/MainPhase.gd").new(),
		preload("res://phases/CombatPhase.gd").new(),
		preload("res://phases/EndPhase.gd").new(),
		preload("res://phases/TurnPhase.gd").new(),
	]

# Start a specific phase
func start_phase(phase: Node) -> void:
	if current_phase:
		current_phase.queue_free()  # Clean up previous phase
	current_phase = phase
	gameboard.add_child(current_phase)
	# Start the phase (ensure that each phase has this method)
	current_phase.call_deferred("start_phase", gameboard)
func reset(gameboard: Node) -> void:
	print("PhaseManager reset")
	# Reset logic here, like starting a new turn or phase
# Start the next phase in the cycle
func start_next_phase() -> void:
	if phase_queue.is_empty():
		enqueue_standard_cycle()  # Refill the phase queue if it's empty
	var next_phase = phase_queue.pop_front()
	start_phase(next_phase)

# Force a phase from a script directly
func force_phase(phase_script: Script) -> void:
	if current_phase:
		current_phase.queue_free()  # Clean up previous phase
	current_phase = phase_script.new()  # Create a new instance from the script
	gameboard.add_child(current_phase)
	current_phase.call_deferred("start_phase", gameboard)
