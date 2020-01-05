extends Node

func get_item(reference:String)-> Node:
	for item in $Equipment.get_children():
		if reference == item.display_name:
			return item.duplicate()
	for item in $BaseFood.get_children():
		if reference == item.display_name:
			return item.duplicate()
	for item in $BaseClothing.get_children():
		if reference == item.display_name:
			return item.duplicate()
	for item in $BaseResorces.get_children():
		if reference == item.display_name:
			return item.duplicate()
	return null

func get_items() -> Array:
	return get_children()

