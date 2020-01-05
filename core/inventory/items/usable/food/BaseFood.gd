#warning-ignore-all:unused_class_variable
extends "res://core/inventory/items/Item.gd"

export(int) var calories := 15
export(int) var ml_of_water = 0
export(ITEM_TYPE) var type = ITEM_TYPE.FOOD

func _apply_effect(user:Node) -> bool:
	if not user.has_node("Metabolism"):
		return false
	if ml_of_water > 0:
		user.get_node("Metabolism").hydrate(ml_of_water, String("Drinking " + String(display_name) + "for "))
	if calories:
		user.get_node("Metabolism").metabolise(calories,String("Metabolising " + String(display_name) + " for "))
		user.get_animation_player().play("eat")
	else:
		user.get_animation_player().play("drink")
	return true
