extends KinematicBody2D

onready var action_menu := $ActionMenu

signal board_train(bording_point,is_bording)

onready var audio := $AudioStreamPlayer2D

onready var boarding_point := $BoardingPoint

export(bool) var IS_MOVING := true setget set_is_moving

var error :int =OK setget on_error
var is_on_train:= false

#action list = "Button Text": "func name called when pressed"
var bording_action_list : Dictionary = {
	"Board":"board_train",
}
var disembark_action_list : Dictionary = {
	"Disembark":'disembark_train',
}

func on_error(new_error)->void:
	error = new_error
	if error != OK:
		print("Error in Train")

func set_is_moving(new_is_moving):
	IS_MOVING = new_is_moving
	if not IS_MOVING:
		$AnimationPlayer.stop()
		$BoardingPoint.set_active(false)
	else:
		is_stil_moving('')
		$BoardingPoint.set_active(true)

func initialize(is_moving = IS_MOVING)-> void:
	print("loading train")
	load_menu()
	IS_MOVING = is_moving
	self.error = $AnimationPlayer.connect("animation_finished",self,"is_stil_moving")
	$AnimationPlayer.play("Moving")

func is_stil_moving(_anim_name) -> void:
	if IS_MOVING:
		$AnimationPlayer.play("Moving")
		if not audio.playing:
			audio.play()
	else:
		$AnimationPlayer.play("stoped")
		audio.stop()

func board_train()->void:
	is_on_train = true
	load_menu()
	emit_signal("board_train",boarding_point,true)
	$ActionMenu.close_menu()
	print("boarding train")

func _on_input_event(_viewport:Viewport, event:InputEvent, _shape_idx:int) ->void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			action_menu.show_menu()
			return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			action_menu.close_menu()

func load_menu()->void:
	action_menu.clear_menu()
	if not is_on_train:
		action_menu.initialize(bording_action_list,self)
	else:
		action_menu.initialize(disembark_action_list,self)
		
func disembark_train()->void:
	is_on_train = false
	load_menu()
	print("disembarking train")
	emit_signal("board_train",boarding_point,false)
