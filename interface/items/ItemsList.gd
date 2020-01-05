extends Control

signal focused_button_changed(button)
signal item_amount_changed(amount)
signal focused_item_changed(item)

export(PackedScene) var ItemButton = preload("res://interface/items/ItemButton.tscn")
onready var _grid = $Grid

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in ItemsList :", error)

func initialize()->void:
	_grid.initialize()

func add_item_button(item:Node, price:float, wallet:Node)->Node:
	var item_button :Button= ItemButton.instance()
	item_button.initialize(item, price, wallet)
	_grid.add_child(item_button)
	self.error = item_button.connect("focus_entered", self, "_on_ItemButton_focus_entered", [item_button, item])
	self.error = item_button.connect("amount_changed", self, "_on_ItemButton_amount_changed")
	return item_button

func _gui_input(event:InputEvent) ->void:
	if not get_focus_owner() == self:
		return
	if event.is_action_pressed('ui_left') or \
		event.is_action_pressed('ui_right') or \
		event.is_action_pressed('ui_up') or \
		event.is_action_pressed('ui_down'):
		$MenuSfx/Navigate.play()
		accept_event()

func get_item_buttons()->Array:
	return _grid.get_children()

func _on_ItemButton_focus_entered(button:Button, item:Node):
	emit_signal("focused_button_changed", button)
	emit_signal("focused_item_changed", item)

func _on_ItemButton_amount_changed(value:int)->void:
	emit_signal("item_amount_changed", value)
	
func clear_buttons()->void:
	_grid.clear_buttons()
