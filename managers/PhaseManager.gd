extends Node

var gameboard: Node = null
var phase_queue: Array = []
var current_phase: Node = null

func init(board: Node) -> void:
	gameboard = board
	phase_queue.clear()

	var startup_phase = preload("res://phases/StartupPhase.gd").new()
	start_phase(startup_phase)
	enqueue_standard_cycle()

func enqueue_standard_cycle() -> void:
	phase_queue = [
		preload("res://phases/DrawPhase.gd").new(),
		preload("res://phases/MainPhase.gd").new(),
		preload("res://phases/CombatPhase.gd").new(),
		preload("res://phases/EndPhase.gd").new(),
		preload("res://phases/TurnPhase.gd").new(),
	]

func start_phase(phase: Node) -> void:
	if current_phase:
		current_phase.queue_free()
	current_phase = phase
	gameboard.add_child(current_phase)
	current_phase.call_deferred("start_phase", gameboard)

func start_next_phase() -> void:
	if phase_queue.is_empty():
		enqueue_standard_cycle()
	var next_phase = phase_queue.pop_front()
	start_phase(next_phase)

func force_phase(phase_script: Script) -> void:
	if current_phase:
		current_phase.queue_free()
	current_phase = phase_script.new()
	gameboard.add_child(current_phase)
	current_phase.call_deferred("start_phase", gameboard)

func reset(board: Node) -> void:
	print("PhaseManager reset")
	init(board)
