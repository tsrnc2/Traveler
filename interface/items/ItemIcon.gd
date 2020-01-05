extends Button
var ITEM : Node
var OWNER : Node

var ClothingInfo :PackedScene = preload("res://interface/menus/inventory/ClothingInfo.tscn")

enum ITEM_TYPE {EQUIPMENT = 0, FOOD = 1, CLOTHING = 2, RESOURCE = 3,}

var error :int= OK setget set_error

func set_error(new_error) -> void:
	error = new_error
	print("Error ItemIcon :", error)

signal amount_changed(value)
var amount := 0
#var is_moving := false

var Actions : Dictionary = {'Use':0,'Move':1,'Trash':2}

var UseMenu := preload("res://interface/items/ItemUseMenu.tscn")

func initialize(item:Node, owner:Node) -> void:
	OWNER = owner
	ITEM = item
	icon = item.icon
	amount = item.amount
	hint_tooltip = item.display_name + '\n' + item.description
	$Label.text = String(amount)

	error = item.connect("amount_changed", self, "_on_Item_amount_changed")
	error = item.connect("depleted", self, "_on_Item_depleted")
	error  = self.connect("pressed", self, "_on_ItemIcon_pressed" )

func _on_Item_depleted():
	disabled = true
	queue_free()

func _on_Item_amount_changed(value):
	amount = value
	$Label.text = String(amount)
	emit_signal("amount_changed", value)

func _on_ItemIcon_pressed():
	if Input.is_action_pressed("selection_mod"):
		var new_menu = UseMenu.instance()
		add_child(new_menu)
		new_menu.connect('action',self,'action_selected')
#		pressed = false
		return
	action_selected(Actions.Use)

func action_selected(selection:int)->void:
	match selection:
		Actions.Use:
			ITEM.use(OWNER)
		Actions.Move:
			move_item()
		Actions.Trash:
#			OWNER.get_inventory().trash(ITEM.display_name)
			ITEM.trash()

func move_item()->void:
	var destination_inventory := get_destination_inventory()
	if not destination_inventory.is_open():
		print('npc inventory is not open')
		return
	destination_inventory.add(ITEM)
	ITEM.trash()

func get_destination_inventory()->Node:
	var selected_npc_inventory = get_tree().get_nodes_in_group("NPCInventoryHUD")[0]
	if OWNER.is_in_group('player'):
		return selected_npc_inventory
	return get_tree().get_nodes_in_group("player")[0]

func _on_ItemIcon_gui_input(event:InputEvent)->void:
	if not ITEM.type == ITEM_TYPE.CLOTHING:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			var info_panel = ClothingInfo.instance()
			add_child(info_panel)
			info_panel.rect_position-=Vector2(32,64)
			info_panel.initialize(ITEM)
