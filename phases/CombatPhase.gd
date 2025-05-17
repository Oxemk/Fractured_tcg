extends Node
class_name CombatPhase

var gameboard: Node

func start_phase(gameboard_instance: Node) -> void:
	print("[CombatPhase] start_phase")
	gameboard = gameboard_instance

	var attacker = _select_attacker_from_front_row(gameboard.PlayerBoard)
	if attacker:
		var target = _select_target(gameboard.EnemyBoard)
		if target:
			print("[CombatPhase] Player attacker %s hits %s" % [attacker.name, target.name])
			_perform_attack(attacker, target)

	var ai_attacker = _select_attacker_from_front_row(gameboard.EnemyBoard)
	if ai_attacker:
		var ai_target = _select_target(gameboard.PlayerBoard)
		if ai_target:
			print("[CombatPhase] AI attacker %s hits %s" % [ai_attacker.name, ai_target.name])
			_perform_attack(ai_attacker, ai_target)

	print("[CombatPhase] Transition to EndPhase")
	PhaseManager.force_phase(preload("res://phases/EndPhase.gd"))

func _select_attacker_from_front_row(board: Node) -> Node:
	for zone in ["troop_slot1", "troop_slot2", "troop_slot3", "Bodyguard_Slot", "DeckMaster_Slot"]:
		var row = board.get_node_or_null(zone)
		if row and row.get_child_count() > 0:
			for card in row.get_children():
				if card.has_method("get_attack_power"):
					return card
	return null

func _select_target(board: Node) -> Node:
	for zone in board.get_children():
		for card in zone.get_children():
			return card
	return null

func _perform_attack(attacker: Node, defender: Node) -> void:
	var atk = _calculate_attack_power(attacker)
	var defp = _calculate_defense_power(defender)
	var dmg = max(atk - defp, 0)
	print("[CombatPhase] Calculated damage: %d" % dmg)
	_apply_damage(defender, dmg)

func _calculate_attack_power(card: Node) -> int:
	var total = card.get_attack_power()
	for child in card.get_children():
		if child.has_method("get_attack_power"):
			total += child.get_attack_power()
	return total

func _calculate_defense_power(card: Node) -> int:
	var total = card.get_defense_power()
	for child in card.get_children():
		if child.has_method("get_defense_power"):
			total += child.get_defense_power()
	return total

func _apply_damage(defender: Node, damage: int) -> void:
	var defp = defender.get_defense_power()
	var spill = max(damage - defp, 0)
	defender.set_defense_power(0)
	var hp = defender.get_hp() - spill
	defender.set_hp(hp)
	print("[CombatPhase] %s HP now %d" % [defender.name, hp])
	if hp <= 0:
		print("[CombatPhase] %s defeated" % defender.name)
		defender.queue_free()
