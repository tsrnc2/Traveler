#warning-ignore-all:unused_class_variable
extends '../Item.gd'

export(ITEM_TYPE) var type := ITEM_TYPE.EQUIPMENT
var is_in_use := false

func _apply_effect(user:Node) -> bool:
	print("Set Equipment ", display_name)
	user.get_inventory().set_equipment(display_name)
	return true
