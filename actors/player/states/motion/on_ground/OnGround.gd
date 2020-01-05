# warning-ignore-all:unused_class_variable
extends "res://actors/player/states/motion/Motion.gd"

var speed := 0.0
var velocity := Vector2()

func handle_input(event:InputEvent):
	if event.is_action_pressed('pickup'):
		emit_signal("finished", 'pickup')
	if event.is_action_pressed("jump"):
		emit_signal("finished", "jump")
	return .handle_input(event)
