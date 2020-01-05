extends Node

onready var wallet := $Wallet

func donate(body:Node)->int:
	randomize()
	var amount = randi() % wallet.coins -1
	wallet.remove_coins(amount)
	body.get_wallet().add_coins(amount)
	return amount
