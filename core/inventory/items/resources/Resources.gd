#warning-ignore-all:unused_class_variable
extends '../Item.gd'

export(ITEM_TYPE) var type := ITEM_TYPE.RESOURCE

func _apply_effect(_user:Node) -> bool:
	get_tree().get_nodes_in_group("InfoHUD")[0].display("Item has no effect on its own")
	print('Item has no effect on its own')
	return false
