extends Control

signal action_completed

onready var tween = $Tween
onready var label = $VBoxContainer/Label
onready var progress_bar = $VBoxContainer/TextureProgress

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in ActionProgress :", error)

func _ready()->void:
	self.error = $VBoxContainer/Button.connect("pressed",self,'cancel_action')
	tween.connect("tween_all_completed",self,'tween_completed')
	visible = false

func set_action(action_name:String)->void:
	label.text = action_name
	
func perform_action(seconds_per_action:float)->void:
	visible = true
	tween.interpolate_property(progress_bar,'value',0,100,seconds_per_action,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func cancel_action()->void:
	if tween.is_active():
		tween.stop_all()
		tween.remove_all()
	progress_bar.value = 0
	tween_completed()

func tween_completed()->void:
	visible = false
	if progress_bar.value == 100:
		emit_signal('action_completed',true)
		return
	emit_signal('action_completed',false)
