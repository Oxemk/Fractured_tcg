extends Node


var pack_prices: Dictionary = {
	"starter_pack": 100,
	"human_pack": 150
}

func purchase_pack(pack_id: String, player_gold: int) -> bool:
	var price = pack_prices.get(pack_id, 0)
	if player_gold >= price:
		var opened = PackManager.open_pack(pack_id)
		for card in opened:
			CardCollectionManager.add_card(card.id)
		return true
	return false
