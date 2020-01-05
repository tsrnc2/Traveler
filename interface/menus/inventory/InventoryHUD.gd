extends Control

onready var _row = $Row

export(PackedScene) var ItemIcon = preload("res://interface/items/ItemIcon.tscn")
export(int) var MAXNUMBEROFITEMS : int = 6 # max number of items on screen at once

var Inventory_Pointer : Node
onready var InventoryMenu := $InventoryMenu

func initialize(inventory_node:Node) -> void:
	Inventory_Pointer = inventory_node
	inventory_node.connect("content_changed", self, 'update_items')
	update_items()

func add_item(item: Node) -> void:
	var item_icon = ItemIcon.instance()
	item_icon.initialize(item,Inventory_Pointer.get_parent())
	_row.add_child(item_icon)

func get_item_icons() -> Node:
		return _row.get_children()

func update_items(updated_item = null) -> void:
	delete_children($Row)
	var num_of_items = Inventory_Pointer.get_num_items()
		#display all items in invintory only up to max
	var list_of_items = Inventory_Pointer.get_items()
	for item in list_of_items:
		if num_of_items >= MAXNUMBEROFITEMS:
			continue
		if item.usable != true:
			continue
		add_item(item)
		
func delete_children(node : Node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
