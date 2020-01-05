extends Control

onready var itemlist := $ItemList

signal action

var Actions : Dictionary = {'Use':0,'Move':1,'Drop':2}

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in ItemUseMenu :", error)

func _ready()->void:
	for action in Actions.keys():
		itemlist.add_item(action)
	self.error = itemlist.connect('item_activated',self,"_on_selection")
	
func update_menu(new_mneu:Dictionary)->void:
	itemlist.clear()
	for action in new_mneu.keys():
		itemlist.add_item(action)	

func show_menu()->void:
	visible = true

func _on_selection(selection:int)->void:
	emit_signal("action",selection)
	visible = false
