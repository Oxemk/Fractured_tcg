extends Control
class_name ShopUI

@onready var starter_btn := $StarterPackButton

func _ready() -> void:
	starter_btn.pressed.connect(_on_starter)

func _on_starter() -> void:
	var gold = 200  # your logic here
	if ShopManager.purchase_pack("starter_pack", gold):
		print("Purchased starter pack")
	else:
		print("Not enough gold")
