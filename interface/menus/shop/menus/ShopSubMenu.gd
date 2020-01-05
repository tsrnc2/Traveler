extends Menu

enum ITEM_TYPE {EQUIPMENT = 0, FOOD = 1, CLOTHING = 2, RESOURCE = 3,}

export(String, "sell_to", "buy_from") var ACTION = ""

export(Color) var INFO_PANEL_COLOR : Color

onready var items_list := $ShopItemsList
onready var description_panel : Control = get_tree().get_nodes_in_group("InfoHUD")[0]
#export(PackedScene) var AMOUNT_POPUP := preload("res://interface/menus/shop/popups/AmountPopup.tscn")

func on_error(new_error)->void:
	new_error = error
	if error != OK:
		print("Error in ShopSubMenu :", error)

func _ready():
	assert ACTION != ""

"""Args: {shop, buyer, items}"""
func initialize(_args={})->void:
	assert _args.size() == 4
	# Extract the nodes from the args dict to preserve legacy code below
	var type : int = _args['type']
	var shop :Node = _args['shop']
	var items :Array = _args['items']
	var buyer :Node = _args['buyer']
	
	var wallet : Node = buyer.get_wallet()
	
	items_list.clear_buttons()
	for item in items:
		if item.type == type and not item.is_queued_for_deletion():
			var price :int = shop.get_buy_value(item) if ACTION == "buy_from" else item.price
			var item_button :Button = items_list.add_item_button(item, price, wallet)
			self.error = item_button.connect("pressed", self, "_on_ItemButton_pressed", [type, shop, buyer, item])
			self.error = item_button.connect("mouse_entered", self, "_on_mouse_hover", [item])
#	items_list.connect("focused_button_changed", self, "_on_ItemList_focused_button_changed")
	items_list.initialize()

func _on_mouse_hover(item_button):
	description_panel.display(item_button.description, INFO_PANEL_COLOR, true)

func open(_args={}):
	.open()
	items_list.get_child(0).set_focus_mode(FOCUS_CLICK)
	items_list.get_child(0).grab_focus()

func close():
	.close()
	description_panel.display('')
	queue_free()

func _on_ItemButton_pressed(_type:int, shop:Node, buyer:Node, item:Node) -> void:
#	var price :float= shop.get_buy_value(item) if ACTION == "buy_from" else item.price
#	var coins :float= shop.get_wallet().coins if ACTION == "buy_from" else buyer.get_wallet().coins
#	var max_amount = min(item.amount, floor(coins / price))

#	var focused_item = get_focus_owner()
#	var popup = AMOUNT_POPUP.instance()
#	add_child(popup)
#	popup.initialize({'value': 1, 'max_value': max_amount})
#	var amount = yield(popup.open(), "amount_confirmed")
#	popup.queue_free()
#	focused_item.grab_focus()
#	if not amount:
#		return
	var amount := 1
	shop.call(ACTION, buyer, item, amount)
