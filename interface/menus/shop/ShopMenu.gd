extends Menu

export(PackedScene) var BuyMenu = preload("res://interface/menus/shop/menus/BuySubMenu.tscn")
export(PackedScene) var SellMenu = preload("res://interface/menus/shop/menus/SellSubMenu.tscn")

onready var buttons = $Column/Buttons
onready var submenu = $Column/Menu
onready var button_buy_equipment = $Column/Buttons/Equipment
onready var button_buy_food = $Column/Buttons/Food
onready var button_buy_clothing = $Column/Buttons/Clothing
onready var button_sell = $Column/Buttons/SellButton

func _ready():
	hide()

signal open_menu

enum ITEM_TYPE {EQUIPMENT = 0, FOOD = 1, CLOTHING = 2, RESOURCE = 3}

"""args: {shop, buyer}"""
func open(args={}) ->void:
	get_tree().paused = true
	assert args.size() == 2
	var shop = args['shop']
	var buyer = args['buyer']
	self.error = button_buy_equipment.connect("pressed", self, "open_submenu",
		[BuyMenu, {
			'type':ITEM_TYPE.EQUIPMENT,
			'shop':shop,
			'buyer':buyer,
			'inventory':shop.inventory}])
	self.error = button_buy_food.connect("pressed", self, "open_submenu",
		[BuyMenu, {
			'type':ITEM_TYPE.FOOD,
			'shop':shop,
			'buyer':buyer,
			'inventory':shop.inventory}])
	self.error = button_buy_clothing.connect("pressed", self, "open_submenu",
		[BuyMenu, {
			'type':ITEM_TYPE.CLOTHING,
			'shop':shop,
			'buyer':buyer,
			'inventory':shop.inventory}])
	self.error = button_sell.connect("pressed", self, "open_submenu",
		[SellMenu, {
			'type':ITEM_TYPE.EQUIPMENT,
			'shop':shop,
			'buyer':buyer,
			'inventory':buyer.get_node("Inventory")}])
	.open()
	buttons.get_child(0).grab_focus()

func close() ->void:
	button_buy_equipment.disconnect('pressed', self, 'open_submenu')
	button_buy_food.disconnect('pressed', self, 'open_submenu')
	button_buy_clothing.disconnect('pressed', self, 'open_submenu')
	button_sell.disconnect('pressed', self, 'open_submenu')
	.close()

"""args: type, shop, buyer, inventory"""
func open_submenu(Menu:PackedScene, args={}) -> void:
	emit_signal('open_menu')
	assert args.size() == 4
	var type :int= args['type']
	var shop :Node= args['shop']
	var buyer :Node= args['buyer']
	var inventory :Node= args['inventory']
	var pressed_button :Button= get_focus_owner()
	var active_menu :Node= Menu.instance()
#	var active_menu :Node= BuyMenu.instance()
	submenu.add_child(active_menu)
	active_menu.initialize({'type':type, 'shop':shop, 'buyer':buyer, 'items':inventory.get_items()})
	self.error = connect('open_menu',active_menu,'close')
	set_process_input(false)
	active_menu.open()
	pressed_button.grab_focus()

func _on_QuitButton_pressed() ->void:
	get_tree().paused = false
	set_process_input(true)
	close()
