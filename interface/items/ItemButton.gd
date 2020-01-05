extends Button

signal amount_changed(value)

var description = ""
var amount = 0

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in ItemButton :", error)

func initialize(item:Node, price:float, wallet:Node) ->void:
	$Name.text = item.display_name
	$Price.text = str(price)
	$Icon.texture = item.icon
	
	description = item.description
	amount = item.amount

	if wallet.coins < price:
		disabled = true
	
	self.error = item.connect("amount_changed", self, "_on_Item_amount_changed")
	self.error = item.connect("depleted", self, "_on_Item_depleted")
	self.error = wallet.connect("coins_changed", self, "_on_Wallet_coins_changed", [price])

func _on_Item_depleted():
	disabled = true

func _on_Item_amount_changed(value):
	amount = value
	emit_signal("amount_changed", value)

func _on_Wallet_coins_changed(coins, price):
	if price > coins:
		disabled = true

func close()->void:
	visible = false
	disabled = true
	queue_free()
