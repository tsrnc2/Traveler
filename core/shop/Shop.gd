extends Node

export(bool) var STOCK_INFINITE := true
export(bool) var MONEY_INFINITE := true

export(int) var MAX_TRANSACTION_COUNT := 100
export(float, 0.0, 1.0) var BUY_MULTIPLIER := 0.25

onready var inventory := $Inventory
onready var wallet := $Wallet

func _ready():
	assert inventory != null

func buy_from(actor :Node, item :Node, amount:int=1) -> void:
	amount = int(clamp(amount, 1, MAX_TRANSACTION_COUNT))
	var transaction_value := max(get_buy_value(item) * amount, wallet.coins)
	actor.get_inventory().trash(item, amount)
	actor.get_wallet().add_coins(transaction_value)
	if not STOCK_INFINITE:
		inventory.add(item, amount)
	if not MONEY_INFINITE:
		wallet.remove_coins(transaction_value)

func sell_to(actor: Node, item:Node, amount:int=1) ->void:
	amount = int(clamp(amount, 1, MAX_TRANSACTION_COUNT))
	actor.get_wallet().remove_coins(item.price * amount)
	actor.get_inventory().add(item.display_name, amount)
	if not STOCK_INFINITE:
		inventory.trash(item.display_name, amount)
	if MONEY_INFINITE:
		return
	wallet.add_coins(item.price * amount)

func get_buy_value(item:Node) ->float:
	return round(item.price * BUY_MULTIPLIER)

func get_wallet() ->Node:
	return wallet
