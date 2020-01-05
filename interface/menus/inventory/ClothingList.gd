extends NinePatchRect

export(PackedScene) var ItemIcon := preload("res://interface/items/ItemIcon.tscn")

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Clothing List :", error)

onready var Equipment_locations := {
		'Hat': $HBox/VBox/Hat,
		'Shirt':$HBox/VBox/Shirt,
		'Gloves':$HBox/VBox/Gloves,
		'Pants':$HBox/VBox/Pants,
		'Footwear':$HBox/VBox/Footwear,
		'Socks':$HBox/VBox2/Socks,
}
enum CLOTHING_TYPE { FOOTWEAR=0, PANTS, SHIRTS, GLOVES, HAT }
var CLOTHING_TYPE_STRING = {CLOTHING_TYPE.FOOTWEAR:"Footwear",
			CLOTHING_TYPE.PANTS:"Pants", CLOTHING_TYPE.SHIRTS:'Shirt',
			CLOTHING_TYPE.GLOVES:'Gloves', CLOTHING_TYPE.HAT:'Hat'}

var Equipment_List : Dictionary
var Player : Node

func initialize(Inventory_Node : Node) -> void:
	self.error = Inventory_Node.connect("equipment_changed", self, "update_equipment")
	Equipment_List = Inventory_Node.get_equipment_list()
	Player = Inventory_Node.get_parent()
	for equipment in Equipment_List.keys():
		update_equipment(Equipment_List.get(equipment))

func update_equipment(new_equipment : Node, type_string :String= '') -> void:
	if new_equipment == null:
		return
	if not type_string:
		type_string = CLOTHING_TYPE_STRING.get(new_equipment.clothing_type)
	make_button(new_equipment, Equipment_locations.get(type_string))

func make_button(new_equipment:Node, new_location : Node) ->void:
	var item_button :Node = ItemIcon.instance()
	item_button.initialize(new_equipment, Player)
	new_location.add_child(item_button)
	new_location.move_child(item_button,0)
