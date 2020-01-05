extends Control

onready var inventory_hud := $Panel/VBox/HBoxContainer/InventoryHUD
var inventory : Node

export(float) var ANIMATION_TIME := 1
export(float) var INVENTORY_SCREEN_ROTATION := 50.0
export(Vector2) var INVENTORY_SCREEN_POS := Vector2(280,350)

onready var tween := $Tween

var start_position : Vector2
var start_rotation : float

var tween_error := true setget on_tween_error

func on_tween_error(new_error:bool)->void:
	tween_error = new_error
	if not tween_error:
		print('Error in NPC Inventory HUD tween')

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in NPC Inventory HUD :", error)

func _ready()->void:
	start_position = rect_position
	start_rotation = rect_rotation
	hide()
#	self.error = $Panel/VBox/Button.connect("pressed",self,"on_Button_pressed")
#
func initialize(npc_name:String, _inventory:Node)->void:
	inventory = _inventory
	$Panel/VBox/Label.text = npc_name
	inventory_hud.initialize(inventory)
	
func show()->void:
	tween.interpolate_property(self,'rect_position',start_position+INVENTORY_SCREEN_POS,start_position,ANIMATION_TIME, Tween.TRANS_ELASTIC,Tween.EASE_OUT)
	tween.interpolate_property(self,'rect_rotation',start_rotation+INVENTORY_SCREEN_ROTATION,0,ANIMATION_TIME, Tween.TRANS_ELASTIC,Tween.EASE_OUT)
	visible = true
	tween.start()

func hide()->void:
	tween.interpolate_property(self,'rect_position',start_position,start_position+INVENTORY_SCREEN_POS,ANIMATION_TIME/2.0, Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()
	yield(tween,'tween_all_completed')
	visible = false

func add(ITEM:Node)->void:
	inventory.add(ITEM.display_name)

func take(ITEM:Node)->void:
	inventory.add(ITEM.display_name)

func _on_Button_pressed():
	hide()

func is_open()->bool:
	return visible
