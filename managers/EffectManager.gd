extends Node
class_name sEffectManager

const EffectType = preload("res://managers/EffectTypes.gd").EffectType
const EffectData = preload("res://managers/EffectData.gd")

func apply_effect(effect_type: int, target_card: Node, value: int) -> void:
	match effect_type:
		EffectType.DAMAGE: apply_damage(target_card, value)
		EffectType.HEAL: apply_heal(target_card, value)
		EffectType.BUFF: apply_buff(target_card, value)
		EffectType.DEBUFF: apply_debuff(target_card, value)
		EffectType.POISON: apply_poison(target_card, value, 3)

func apply_damage(target_card: Node, value: int) -> void:
	if target_card.has_method("apply_damage"):
		target_card.apply_damage(value)
	elif target_card.has("health"):
		target_card.health = max(target_card.health - value, 0)

func apply_heal(target_card: Node, value: int) -> void:
	if target_card.has("health"):
		target_card.health = min(target_card.health + value, target_card.max_health)

func apply_buff(target_card: Node, value: int) -> void:
	if target_card.has("attack_move"):
		target_card.attack_move["damage"] += value

func apply_debuff(target_card: Node, value: int) -> void:
	if target_card.has("defense"):
		target_card.defense = max(target_card.defense - value, 0)

func apply_poison(target: Node, damage_per_turn: int, duration: int) -> void:
	if target.has_method("add_effect_duration"):
		var poison_effect = EffectData.new(EffectType.POISON, damage_per_turn, duration)
		target.add_effect_duration(poison_effect)

func update_effects_for_card(target: Node) -> void:
	if target.has_method("update_effects"):
		target.update_effects()
