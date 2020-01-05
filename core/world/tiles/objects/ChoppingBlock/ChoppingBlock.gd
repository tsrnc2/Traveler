extends Node2D

export(float) var CHOPPING_TIME := 2.5 # Seconds

var chopping_action_list : Dictionary = {'Chop':'on_chopping_clicked' }

onready var action_menu = $ActionMenu

var target : Node

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Choppingblock:", error)

func initialize(_target)->void:
	target = _target
	action_menu.clear_menu()
	action_menu.initialize(chopping_action_list,self)
	$ActionProgress.set_action('Chopping')
	error = $ActionProgress.connect("action_completed",self,'copping_completed')
	
func on_chopping_clicked()->void:
	$ActionProgress.perform_action(CHOPPING_TIME)

func copping_completed()->void:
	target.get_inventory().add('Wood')

func _on_ChoppingBlock_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print('showing menu')
			action_menu.show_menu()
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			print('Closing menu')
			action_menu.close_menu()
