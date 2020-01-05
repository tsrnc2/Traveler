extends Area2D

var action_list : Dictionary = {"Shop":"open_shop_menu",}

func _ready()->void:
	$ActionMenu.initialize(action_list,self)

signal shop_open_requested(shop,user)

const Player = preload("res://actors/player/PlayerController.gd")

#func _unhandled_input(event):
#	if not event.is_action_pressed("ui_accept"):
#		return
#	for body in get_overlapping_bodies():
#		if body is Player:
#			emit_signal("shop_open_requested", $Shop, body)
#			get_tree().paused = true
#			get_tree().set_input_as_handled()

func _on_Seller_input_event(_viewport:Viewport, event:InputEvent, _shape_idx:int)->void:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
					$ActionMenu.show_menu()

func open_shop_menu()->void:
	for body in get_overlapping_bodies():
		if body is Player:
			emit_signal("shop_open_requested", $Shop, body)
			$ActionMenu.close_menu()
			return
	get_tree().get_nodes_in_group("InfoHUD")[0].display("You must be closer to enter store")
