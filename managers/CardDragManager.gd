extends Node

var dragging := false
var dragged_card: Node = null
var drag_offset := Vector2.ZERO
var original_parent: Node = null
var original_position: Vector2 = Vector2.ZERO

func handle_card_input(card: Node, event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _is_mouse_over(card):
					_start_drag(card, event.position)
			else:
				if dragging and dragged_card == card:
					_stop_drag(event.position)
	elif event is InputEventMouseMotion and dragging and dragged_card == card:
		_drag(event.position)

func _is_mouse_over(card: Node) -> bool:
	var card_rect := Rect2(card.global_position - Vector2(50, 75), Vector2(100, 150))
	return card_rect.has_point(card.get_global_mouse_position())

func _start_drag(card: Node, mouse_pos: Vector2) -> void:
	dragging = true
	dragged_card = card
	original_parent = card.get_parent()
	original_position = card.position
	drag_offset = mouse_pos - card.global_position

	if original_parent:
		original_parent.remove_child(card)
	get_tree().get_root().add_child(card)
	card.global_position = mouse_pos - drag_offset

func _drag(mouse_pos: Vector2) -> void:
	if dragged_card:
		dragged_card.global_position = mouse_pos - drag_offset

func _stop_drag(mouse_pos: Vector2) -> void:
	dragging = false
	if not dragged_card:
		return

	var drop_zone = _find_drop_zone(mouse_pos)
	if drop_zone:
		drop_zone.add_child(dragged_card)
		dragged_card.position = Vector2.ZERO
	else:
		original_parent.add_child(dragged_card)
		dragged_card.position = original_position

	dragged_card = null

func _find_drop_zone(mouse_pos: Vector2) -> Node:
	var zone_paths := [
		"/root/GameBoard/troop_slot1",
		"/root/GameBoard/troop_slot2",
		"/root/GameBoard/troop_slot3",
		"/root/GameBoard/Bodyguard_Slot",
		"/root/GameBoard/DeckMaster_Slot"
	]
	for path in zone_paths:
		var zone = get_node_or_null(path)
		if zone:
			var zone_rect := Rect2(zone.global_position - Vector2(50, 75), Vector2(100, 150))
			if zone_rect.has_point(mouse_pos):
				return zone
	return null
