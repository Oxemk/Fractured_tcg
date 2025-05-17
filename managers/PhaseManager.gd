extends Node
# PhaseManager singleton: controls phase transitions with debug logging

var gameboard: Node = null
var phase_queue: Array = []
var current_phase: Node = null
var paused: bool = false

func init(board: Node) -> void:
	print("[PhaseManager] init called")
	gameboard = board
	phase_queue.clear()
	paused = false

	# Run StartupPhase for Player 1
	print("[PhaseManager] Running StartupPhase for Player 1")
	var startup_p1 = preload("res://phases/StartupPhase.gd").new()
	gameboard.add_child(startup_p1)
	startup_p1.start_phase(gameboard, true)

	# Run StartupPhase for Player 2/AI
	print("[PhaseManager] Running StartupPhase for Player 2/AI")
	var startup_p2 = preload("res://phases/StartupPhase.gd").new()
	gameboard.add_child(startup_p2)
	startup_p2.start_phase(gameboard, false)

	# Queue the repeating Yu-Gi-Oh style cycle
	print("[PhaseManager] Enqueuing standard phase cycle")
	enqueue_standard_cycle()

	# Kick off the first Draw phase
	print("[PhaseManager] Starting first queued phase")
	start_next_phase()

func enqueue_standard_cycle() -> void:
	print("[PhaseManager] enqueue_standard_cycle called")
	phase_queue = [
		preload("res://phases/DrawPhase.gd"),
		preload("res://phases/StandbyPhase.gd"),
		preload("res://phases/MainPhase.gd"),
		preload("res://phases/CombatPhase.gd"),
		preload("res://phases/MainPhase.gd"),
		preload("res://phases/EndPhase.gd"),
		preload("res://phases/TurnPhase.gd"),
	]
	print("[PhaseManager] Queue size: %d" % phase_queue.size())

func start_phase(phase_script: Script) -> void:
	print("[PhaseManager] start_phase: %s" % phase_script)
	if current_phase:
		current_phase.queue_free()
	current_phase = phase_script.new()
	gameboard.add_child(current_phase)
	current_phase.call_deferred("start_phase", gameboard)

func start_next_phase() -> void:
	print("[PhaseManager] start_next_phase, paused=%s" % paused)
	if paused:
		return
	if phase_queue.size() == 0:
		print("[PhaseManager] Queue empty, re-enqueuing")
		enqueue_standard_cycle()
	var next_script = phase_queue.pop_front()
	print("[PhaseManager] Popped phase: %s" % next_script)
	start_phase(next_script)

func force_phase(phase_script: Script) -> void:
	print("[PhaseManager] force_phase: %s" % phase_script)
	if current_phase:
		current_phase.queue_free()
	current_phase = phase_script.new()
	gameboard.add_child(current_phase)
	current_phase.call_deferred("start_phase", gameboard)

func pause() -> void:
	paused = true
	print("[PhaseManager] paused")

func resume() -> void:
	paused = false
	print("[PhaseManager] resumed")
	start_next_phase()

func reset(board: Node) -> void:
	print("[PhaseManager] reset")
	init(board)

# --- Phase Scripts with Logging ---

# DrawPhase.gd
