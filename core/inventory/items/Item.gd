#warning-ignore-all:unused_class_variable
extends Node

signal amount_changed(amount)
signal depleted()

enum ITEM_TYPE {EQUIPMENT = 0, FOOD = 1, CLOTHING = 2, RESOURCE = 3,}
# warning-ignore:unused_class_variable
export(Texture) var icon : Texture
export(String) var display_name := ""
export(String) var description := ""
# warning-ignore:unused_class_variable
export(int) var price := 100
export(int) var weight := 1

export(int) var amount := 1 setget set_amount

export(float) var condition := 100
export(bool) var unique := false
export(bool) var usable := true

func use(user:Node) -> bool:
	if amount == 0:
		return false
	if self.type == ITEM_TYPE.EQUIPMENT:
		return _apply_effect(user)
	if usable and not unique and _apply_effect(user):
		self.amount -= 1
		emit_signal("amount_changed", amount)
		return true
	get_tree().get_nodes_in_group("InfoHUD")[0].display( String('Cant use '+ display_name+ ' On '+ user.name))
	print('Cant use ', display_name, ' On ', user.name)
	return false

func trash() -> void:
	if amount == 0:
		return
	self.amount -= 1
	emit_signal("amount_changed", amount)
	if amount == 0:
		queue_free()
		emit_signal("depleted")

#warning-ignore:narrowing_conversion
func set_amount(value:int) ->void:
	amount = max(0, value)
	emit_signal("amount_changed", amount)
	if amount == 0:
		queue_free()
		emit_signal("depleted")

# warning-ignore:unused_argument
func _apply_effect(user: Node) ->bool:
	print("Item %s has no apply_effect override" % name)
	return false

