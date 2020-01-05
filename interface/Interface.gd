extends CanvasLayer

export(NodePath) var SUB_MENU_PATH : NodePath

const InventoryMenu = preload("res://interface/menus/inventory/InventoryMenu.tscn")
onready var shop_menu = $ShopMenu
var is_inventory_open :=  false

export(String) var TALKABLE_NPC_GROUP_NAME := 'npc'
export(String) var SPAWNABLE_NPC_GROUP_NAME := 'npc_spawner'

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Interface :", error)

func _ready():
	shop_menu.connect('closed', self, 'remove_child', [shop_menu])
	remove_child(shop_menu)

func initialize(player):
	$PlayerHUD.initialize(player.get_wallet(), player.get_metabolism(), player.get_stamina(), player.get_wanted_node(), $PlayerOverview)
	$InventoryHUD.initialize(player.get_inventory())
	$PauseLayer/PauseMenu.initialize({'actor': player})
	$MapPanel.initialize(player)
	$PlayerOverview.initialize(player.get_metabolism(), player.get_stamina())
	self.error = player.connect('open_inventory', self, 'open_sub_menu', [InventoryMenu, {'inventory':player.get_inventory()}])
	self.error = player.connect('open_sign_maker', self, 'open_sign_maker')

func open_sign_maker():
	$SignDesigner.visible = not $SignDesigner.visible
	
func open_sub_menu(menu, args:={})->void:
	if menu == InventoryMenu:
		if is_inventory_open:
			return
		is_inventory_open = true	
	var sub_menu :Menu= menu.instance() if menu is PackedScene else menu
	if SUB_MENU_PATH:
		get_node(SUB_MENU_PATH).add_child(sub_menu)
	else:
		add_child(sub_menu)
	sub_menu.initialize(args)
	set_process_input(false)
# warning-ignore:return_value_discarded
	sub_menu.open(args)
	yield(sub_menu, "closed")
	if menu == InventoryMenu:
		is_inventory_open = false
	set_process_input(true)
	remove_child(sub_menu)
	
func _on_Level_loaded(_level:Node)->void:
	var tree = get_tree()
	for seller in tree.get_nodes_in_group('seller'):
		seller.connect('shop_open_requested', self, 'shop_open')
#	var monsters = tree.get_nodes_in_group('monster')
#	var spawners = tree.get_nodes_in_group('monster_spawner')
#	$LifebarsBuilder.initialize(monsters, spawners)
	$"../GameClock".initialize()
	$EnviromentHUD/ClockHUD.initialize($"../GameClock")
	$EnviromentHUD/WeatherHUD.initialize(get_tree().get_nodes_in_group("weather")[0])
	$QuoteBarBuilder.initialize(TALKABLE_NPC_GROUP_NAME,SPAWNABLE_NPC_GROUP_NAME)

func shop_open(seller_shop:Node, buyer:Node) ->void:
	add_child(shop_menu)
	shop_menu.open({'shop': seller_shop, 'buyer': buyer})

func open_npc_inventory(npc_name:String, npc_inventory:Node)->void:
	$NPCInventory.initialize(npc_name, npc_inventory)
	$NPCInventory.show()
