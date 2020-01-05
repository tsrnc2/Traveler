extends Node

signal coins_changed(coins)

export(int) var coins := 0 setget change_coin_value
export(int) var MAXIMUM := 1000000

func change_coin_value(new_coin_value:int) -> void:
	#warning-ignore#narrowing_conversion
	coins = int(clamp(new_coin_value, 0, MAXIMUM))
	emit_signal("coins_changed",coins)

func has_coins(amount:int) -> bool:
	return coins >= amount

func add_coins(amount:int) -> void:
	self.coins += amount

func remove_coins(amount:int) ->void:
	self.coins -= amount
