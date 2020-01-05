extends Node

signal content_changed(items_as_string)
signal item_added(item)
signal item_removed(item)
signal equipment_changed(item)

enum CLOTHING_TYPE { FOOTWEAR=0, PANTS, SHIRTS, GLOVES, HAT }

enum ITEM_TYPE {EQUIPMENT = 0, FOOD = 1, CLOTHING = 2, RESORCE = 3,}

var CLOTHING_TYPE_STRING = {CLOTHING_TYPE.FOOTWEAR:"Footwear",
			CLOTHING_TYPE.PANTS:"Pants", CLOTHING_TYPE.SHIRTS:'Shirt',
			CLOTHING_TYPE.GLOVES:'Gloves', CLOTHING_TYPE.HAT:'Hat'}

var EquipmentList = {}

var error:int = OK setget on_error

func on_error(new_error) -> void:
	error = new_error
	if error != OK:
		print("Error in Inventory : ", error)

func get_items():
	return get_children()

func get_num_items() -> int:
	var i := 0
	for child in get_children():
		i =+ 1
	return i
	
func find_item(reference:String):
	for item in get_items():
		if item.display_name == reference:
			return item

func has(item:String):
	return true if find_item(item) else false

func get_count(reference:String) -> int:
	var item = find_item(reference)
	return item.amount if item else 0

func add(reference:String, amount=1) -> void:
	var item = find_item(reference)
	if not item:
		item = _instance_item_from_db(reference)
		amount -= item.amount
	if not item :
		print("cant find ", reference)
		return
	item.amount += amount
	emit_signal("content_changed", get_content_as_string())

func trash(reference:String, amount := 0) -> void:
	var item = find_item(reference)
	if not item:
		print('item not found')
		print(reference)
		return
	if amount == 0:
		return
	item.amount -= amount
	emit_signal("content_changed", get_content_as_string())

func use(item:Node, user:Node):
	item.use(user)
	emit_signal("content_changed", get_content_as_string())

func get_content_as_string() -> String:
	var string := ""
	for item in get_items():
		if item.amount == 0:
			continue
		string += "%s: %s" % [item.display_name, item.amount]
		string += "\n"
	return string

func _instance_item_from_db(reference : String) -> Node:
	var item :Node = ItemDatabase.get_item(reference)
	if item:
		add_child(item)
		self.error = item.connect("depleted", self, "_on_Item_depleted", [item])
		emit_signal("item_added", item)
	return item

func _on_Item_depleted(item : Node) -> void:
	emit_signal("item_removed", item)
	
func set_equipment(new_equipment_string:String) -> void:
	var new_equipment = find_item(new_equipment_string)
	if new_equipment.type == ITEM_TYPE.CLOTHING:
		var type_string :String = CLOTHING_TYPE_STRING.get(new_equipment.clothing_type)
		if EquipmentList.has(type_string):
			EquipmentList.get(type_string).is_in_use = false
			EquipmentList.erase(type_string)
		EquipmentList[type_string] = new_equipment
		new_equipment.is_in_use = true
		emit_signal("equipment_changed", new_equipment, type_string)
	
func get_equipment_list() -> Dictionary:
	return EquipmentList

