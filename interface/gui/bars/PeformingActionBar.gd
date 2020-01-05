extends Control

signal action_complete

export(String) var Action:String setget new_action
export(float) var Time:float

onready var progress_bar := $Panel/VBox/TextureProgress
onready var label : = $Panel/VBox/Label

var tween : Tween

var tween_error : bool= false setget on_tween_error
var error :int = OK setget on_error

func on_tween_error(new_error:bool)->void:
	tween_error = new_error
	if !tween_error:
		print("error in ActionBar tween")

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("error in ActionBar", error)

func initialize(_action=Action, _time = Time)->void:
	label.text = _action
	visible = true
	tween = Tween.new()
	add_child(tween)
	progress_bar.value = 0
	self.error = tween.connect("tween_all_completed",self,"action_complete")
	self.tween_error = tween.interpolate_property(progress_bar,'value',0,100,_time,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	self.tween_error = tween.start()
	
func new_action(_action)->void:
	Action = _action
	label.text  = _action

func action_complete()->void:
	hide()
	emit_signal("action_complete")
	
func hide()->void:
	visible = false
