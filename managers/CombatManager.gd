extends Node


func apply_damage(target: Node, amount: int) -> void:
	var rem = amount
	if target.defense > 0:
		var d = min(target.defense, rem)
		target.defense -= d
		rem -= d
	if rem > 0:
		target.health -= rem
	print("Applied %d dmg to %s → DEF:%d HP:%d" %
		[amount, target.card_name, target.defense, target.health])

func heal_hp(target: Node, amount: int) -> void:
	target.health += amount
	print("Healed %s by %d" % [target.card_name, amount])

func repair_armor(target: Node, amount: int) -> void:
	target.defense += amount
	print("Repaired %s armor by %d" % [target.card_name, amount])
