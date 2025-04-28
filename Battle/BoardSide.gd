	extends Node2D
	class_name BoardSide

	@export var side_id: int = 1  # 1 = Player1, 2 = Player2

	# Row nodes
	@onready var troop_row:    Node2D = $TroopRow
	@onready var bodyguard_row:Node2D = has_node("BodyguardRow") ? $BodyguardRow : null
	@onready var deckmaster_row:Node2D = $DeckmasterRow

	# Internal list of slots and their zones
	var _slots: Array = []

	func _ready() -> void:
		# Scan each row and register all its slots
		for row in [troop_row, bodyguard_row, deckmaster_row]:
			if row:
				for slot in row.get_children():
					_register_slot(slot)

	func _register_slot(slot: Node) -> void:
		# Expect each slot to have these child nodes:
		#   WeaponZone, ArmorZone, ClassZone, SupportTrapZone
		var zones = {
			"weapon":       slot.get_node_or_null("WeaponZone"),
			"armor":        slot.get_node_or_null("ArmorZone"),
			"class":        slot.get_node_or_null("ClassZone"),
			"support_trap": slot.get_node_or_null("SupportTrapZone")
		}
		_slots.append({
			"slot_node": slot,
			"zones": zones
		})

	func equip_card_to_slot(slot_index: int, card_scene: PackedScene, zone_type: String) -> Node:
		# Map incoming zone_type ("support" or "trap") to our single key
		var key = zone_type in ["support", "trap"] ? "support_trap" : zone_type
		var slot_info = _slots[slot_index]
		var zone = slot_info.zones.get(key, null)
		if not zone:
			push_error("BoardSide: Slot %d has no '%s' zone." % [slot_index, key])
			return null

		# Clear out any existing card
		for child in zone.get_children():
			child.queue_free()

		# Instance and center the new card
		var card_inst = card_scene.instantiate()
		zone.add_child(card_inst)
		card_inst.position = Vector2.ZERO
		return card_inst

	# Convenience if your card scenes define a `card_type` property
	func equip_card(slot_index: int, card_scene: PackedScene) -> void:
		var card_type = card_scene.get("card_type", "")
		match card_type:
			"Weapon":
				equip_card_to_slot(slot_index, card_scene, "weapon")
			"Armor":
				equip_card_to_slot(slot_index, card_scene, "armor")
			"Class":
				equip_card_to_slot(slot_index, card_scene, "class")
			"Support", "Trap":
				equip_card_to_slot(slot_index, card_scene, "support")
			_:
				push_warning("BoardSide: Unknown card_type '%s'" % card_type)

	func get_all_zones(zone_type: String) -> Array:
		# Returns all zones of that type (weapon, armor, class, or support_trap)
		var key = zone_type in ["support", "trap"] ? "support_trap" : zone_type
		var out = []
		for info in _slots:
			var z = info.zones.get(key, null)
			if z:
				out.append(z)
		return out
