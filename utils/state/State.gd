"""
Base interface for all states: it doesn't do anything in itself
but forces us to pass the right arguments to the methods below
and makes sure every State object had all of these methods.
"""
extends Node

var error :int= OK setget on_error

func on_error(new_error:int) ->void:
	error = new_error
	if error != OK:
		print("Error in statemachine :", error)

# warning-ignore:unused_signal
signal finished(next_state_name)

func enter() ->void:
	return

func exit() ->void:
	return

func handle_input(_event:InputEvent):
	return

func update(_delta) -> void:
	return

func _on_animation_finished(_anim_name) -> void:
	return
