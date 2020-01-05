extends NinePatchRect

onready var _row = $Row

export(PackedScene) var ItemIcon = preload("res://interface/items/ItemIcon.tscn")
export(int) var MAXNUMBEROFITEMS : int = 6 # max number of items on screen at once

var Inventory_Pointer : Node

var error : int = OK setget on_error

func on_error(new_error:int) ->void:
	new_error = error
	if error != OK:
		print("Error in InventoryHUD :", error)

func initialize(inventory_node:Node) -> void:
	Inventory_Pointer = inventory_node
	self.error = inventory_node.connect("content_changed", self, 'update_items')
	update_items()
	
func add_item(item: Node) -> void:
	var item_icon :Node = ItemIcon.instance()
	item_icon.initialize(item,Inventory_Pointer.get_parent())
	_row.add_child(item_icon)

func get_item_icons() -> Node:
		return _row.get_children()

# warning-ignore:unused_argument
func update_items(updated_item = null) -> void:
	delete_children($Row)
	var num_of_items := 0
		#display all items in invintory only up to max
	var list_of_items :Array = Inventory_Pointer.get_items()
	for item in list_of_items:
		if item.usable and num_of_items < MAXNUMBEROFITEMS:
			add_item(item)
			num_of_items += 1
		
func delete_children(node : Node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
