extends Control

enum ITEM_TYPE {EQUIPMENT = 0, FOOD = 1, CLOTHING = 2, RESORCE = 3,}

#export var MAXNUMBEROFITEMS := 20

var item_type_limiter := -1

export(PackedScene) var ItemIcon := preload("res://interface/items/ItemIcon.tscn")
onready var grid := $Grid
var INVENTORY_POINTER : Node

var error :int= OK setget on_error

func on_error(new_error:int) -> void:
	error = new_error
	print ("Error in BackpackList :", error)

func initialize(inventory_node:Node) -> void:
	INVENTORY_POINTER = inventory_node
	error = inventory_node.connect("content_changed", self, 'update_items')
	error = inventory_node.connect("equipment_changed", self, 'equipment_changed')
	update_items()

func equipment_changed(_updated_item:Node, _type:String)-> void:
	update_items()

func update_items(_updated_item = null) -> void:
	delete_children(grid)
	#warning-ignore:unused_variable
	var num_of_items := 0
		#display all items in invintory only up to max
	var list_of_items :Array = INVENTORY_POINTER.get_items()
	for item in list_of_items:
		if item_type_limiter != -1:
			if item.type != item_type_limiter:
				continue
		if item.type == ITEM_TYPE.CLOTHING and item.is_in_use:
			continue
		add_item(item)
		num_of_items += 1

func set_item_type_limiter(new_limiter:int) -> void:
	item_type_limiter = new_limiter
	update_items()

func delete_children(node : Node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
func add_item(item: Node) -> void:
	var item_icon :Node = ItemIcon.instance()
	item_icon.initialize(item,INVENTORY_POINTER.get_parent())
	grid.add_child(item_icon)
