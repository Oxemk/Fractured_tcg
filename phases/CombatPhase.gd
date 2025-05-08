extends Node
class_name CombatPhase

func start_phase(gameboard) -> void:
	# 1) Enable any combat‐specific UI
	gameboard.enable_combat_ui()

	# 2) Example combat logic: each side deals damage to the other
	#    (You can replace this with your own turn‐based or simultaneous logic.)

	# Gather all card nodes under each board
	var players = gameboard.PlayerBoard.get_children()
	var enemies = gameboard.EnemyBoard.get_children()

	# Each player card attacks each enemy card (example)
	for p_card in players:
		if p_card.has_method("get_attack_power"):
			var atk = p_card.get_attack_power()
			for e_card in enemies:
				CombatManager.apply_damage(e_card, atk)

	# Each enemy card retaliates against each player card
	for e_card in enemies:
		if e_card.has_method("get_attack_power"):
			var atk = e_card.get_attack_power()
			for p_card in players:
				CombatManager.apply_damage(p_card, atk)

	# 3) After resolving all combat actions, advance to EndPhase
	gameboard.switch_to_phase(preload("res://phases/EndPhase.gd").new())
