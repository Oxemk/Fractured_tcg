extends Node
class_name CombatPhase

var gameboard: Node
var selected_attacker: Node = null

func start_phase(gameboard_instance: Node) -> void:
	print("[CombatPhase] start_phase – waiting for player input")
	gameboard = gameboard_instance

	# Pause the manager so it doesn’t auto‑advance
	PhaseManager.pause()

	# Highlight selectable attackers and connect their click()
	_highlight_front_row(true)
	_connect_attacker_signals()

# Called by your card scene when the player clicks an attacker
func on_player_attacker_selected(attacker: Node) -> void:
	if not attacker:
		return
	selected_attacker = attacker
	print("[CombatPhase] Player selected attacker: %s" % attacker.name)

	_highlight_front_row(false)
	# Now highlight possible targets
	_highlight_enemy_board(true)
	_connect_target_signals()

# Called by your card scene when the player clicks a target
func on_player_target_selected(defender: Node) -> void:
	if not selected_attacker or not defender:
		return
	print("[CombatPhase] Player %s → %s" % [selected_attacker.name, defender.name])

	# Clean up highlights & signals
	_highlight_enemy_board(false)
	_disconnect_all_signals()

	# Perform the player’s attack
	_perform_attack(selected_attacker, defender)
	selected_attacker = null

	# Do the AI’s attack automatically, then advance
	_ai_turn_and_finish()

func _ai_turn_and_finish() -> void:
	# AI picks and attacks
	var ai_attacker = _find_any_attacker(gameboard.EnemyBoard)
	var ai_defender: Node = null
	if ai_attacker:
		ai_defender = _find_any_target(gameboard.PlayerBoard)
	if ai_attacker and ai_defender:
		print("[CombatPhase] AI %s → %s" % [ai_attacker.name, ai_defender.name])
		_perform_attack(ai_attacker, ai_defender)

	# Resume and force EndPhase
	print("[CombatPhase] transitioning to EndPhase")
	PhaseManager.resume()
	PhaseManager.force_phase(preload("res://phases/EndPhase.gd"))

# ──────── Helpers ─────────

func _find_any_attacker(board: Node) -> Node:
	for zone_name in ["troop_slot1","troop_slot2","troop_slot3","Bodyguard_Slot","DeckMaster_Slot"]:
		var row = board.get_node_or_null(zone_name)
		if row:
			for c in row.get_children():
				if c.has_method("get_attack_power"):
					return c
	return null

func _find_any_target(board: Node) -> Node:
	for zone in board.get_children():
		for c in zone.get_children():
			return c
	return null

func _perform_attack(attacker: Node, defender: Node) -> void:
	var atk = _calc_atk(attacker)
	var defp = _calc_def(defender)
	var dmg = max(atk - defp, 0)
	print("[CombatPhase] damage = %d" % dmg)
	_apply_damage(defender, dmg)

func _calc_atk(c: Node) -> int:
	var t = c.get_attack_power()
	for child in c.get_children():
		if child.has_method("get_attack_power"):
			t += child.get_attack_power()
	return t

func _calc_def(c: Node) -> int:
	var t = c.get_defense_power()
	for child in c.get_children():
		if child.has_method("get_defense_power"):
			t += child.get_defense_power()
	return t

func _apply_damage(defender: Node, damage: int) -> void:
	var defp = defender.get_defense_power()
	var spill = max(damage - defp, 0)
	defender.set_defense_power(0)
	var new_hp = defender.get_hp() - spill
	defender.set_hp(new_hp)
	print("[CombatPhase] %s HP now %d" % [defender.name, new_hp])
	if new_hp <= 0:
		print("[CombatPhase] %s defeated" % defender.name)
		defender.queue_free()

# ─── Highlight & Signals ───

func _highlight_front_row(enable: bool) -> void:
	for zone_name in ["troop_slot1","troop_slot2","troop_slot3","Bodyguard_Slot","DeckMaster_Slot"]:
		var row = gameboard.PlayerBoard.get_node_or_null(zone_name)
		if row:
			for c in row.get_children():
				if c.has_method("set_selectable"):
					c.set_selectable(enable)

func _highlight_enemy_board(enable: bool) -> void:
	for zone in gameboard.EnemyBoard.get_children():
		for c in zone.get_children():
			if c.has_method("set_selectable"):
				c.set_selectable(enable)

func _connect_attacker_signals() -> void:
	for zone_name in ["troop_slot1","troop_slot2","troop_slot3","Bodyguard_Slot","DeckMaster_Slot"]:
		var row = gameboard.PlayerBoard.get_node_or_null(zone_name)
		if row:
			for c in row.get_children():
				if c.has_signal("pressed"):
					c.connect("pressed", self, "on_player_attacker_selected", [c])

func _connect_target_signals() -> void:
	for zone in gameboard.EnemyBoard.get_children():
		for c in zone.get_children():
			if c.has_signal("pressed"):
				c.connect("pressed", self, "on_player_target_selected", [c])

func _disconnect_all_signals() -> void:
	# This stub removes all connections; implement as needed
	pass
