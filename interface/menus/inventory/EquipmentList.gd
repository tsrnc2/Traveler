extends NinePatchRect

enum ITEM_TYPE {EQUIPMENT = 0, FOOD = 1, CLOTHING = 2, RESORCE = 3,}

export var MAXNUMBEROFITEMS := 20

export(PackedScene) var ItemIcon := preload("res://interface/items/ItemIcon.tscn")
onready var grid := $"VBox/Grid"
var INVENTORY_POINTER : Node

func initialize(Inventory_Node : Node) -> void:
	INVENTORY_POINTER = Inventory_Node
	Inventory_Node.connect("content_changed", self, 'update_items')
	Inventory_Node.connect("equipment_changed", self, 'update_items')
	update_items()

func update_items(updated_item = null, item_type = null) -> void:
	delete_children(grid)
	var num_of_items := 0
		#display all items in invintory only up to max
	var list_of_items :Array = INVENTORY_POINTER.get_items()
	for item in list_of_items:
		if (item.type == ITEM_TYPE.EQUIPMENT or item.type == ITEM_TYPE.CLOTHING) and not item.is_in_use:
			add_item(item)
			num_of_items += 1

func delete_children(node : Node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
func add_item(item: Node) -> void:
	var item_icon :Node = ItemIcon.instance()
	item_icon.initialize(item,INVENTORY_POINTER.get_parent())
	grid.add_child(item_icon)
