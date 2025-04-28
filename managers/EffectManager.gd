extends Node
# (Removed `class_name EffectManager` to avoid hiding the singleton)

enum EffectType { DAMAGE, HEAL, BUFF, DEBUFF, POISON }

# ---------------- General Effects ----------------

func apply_effect(effect_type: EffectType, target_card: Node, value: int) -> void:
	match effect_type:
		EffectType.DAMAGE:
			apply_damage(target_card, value)
		EffectType.HEAL:
			apply_heal(target_card, value)
		EffectType.BUFF:
			apply_buff(target_card, value)
		EffectType.DEBUFF:
			apply_debuff(target_card, value)
		EffectType.POISON:
			# Default poison duration is 3 turns
			apply_poison(target_card, value, 3)

func apply_damage(target_card: Node, value: int) -> void:
	if target_card.has_method("apply_damage"):
		target_card.apply_damage(value)
	else:
		target_card.health = max(target_card.health - value, 0)
	print("Applied damage: %d to %s" % [value, target_card.name])

func apply_heal(target_card: Node, value: int) -> void:
	target_card.health += value
	print("Healed %s for %d" % [target_card.name, value])

func apply_buff(target_card: Node, value: int) -> void:
	if target_card.has("attack_move"):
		target_card.attack_move["damage"] += value
	print("Buffed %s's attack by %d" % [target_card.name, value])

func apply_debuff(target_card: Node, value: int) -> void:
	if target_card.has("defense"):
		target_card.defense = max(target_card.defense - value, 0)
	print("Debuffed %s's defense by %d" % [target_card.name, value])

# ---------------- Poison Effect ----------------

func apply_poison(target: Node, damage_per_turn: int, duration: int) -> void:
	# Queue up a duration‐based poison effect
	start_effect_duration(target, EffectType.POISON, duration)
	print("Applied poison to %s: %d damage/turn for %d turns" % [target.name, damage_per_turn, duration])

func spread_poison_to_adjacent(target: Node, damage_per_turn: int, duration: int, spread_range: int) -> void:
	var adjacent_cards = get_adjacent_cards(target)
	for card in adjacent_cards:
		if spread_range > 0:
			apply_poison(card, damage_per_turn, duration)

# ---------------- Race-specific Abilities ----------------
# (unchanged from before, but now POISON is valid if you ever want to queue it)

# ---------------- Duration-Based Effects ----------------

func start_effect_duration(target: Node, effect_type: EffectType, duration: int) -> void:
	if target.has_method("add_effect_duration"):
		target.add_effect_duration(effect_type, duration)

# ---------------- Stubs ----------------

func get_adjacent_cards(target: Node) -> Array:
	# TODO: implement your board logic
	return []
