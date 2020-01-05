"""
Base interface for a generic state machine
It handles initializing, setting the machine active or not
delegating _physics_process, _input calls to the State nodes,
and changing the current/active state.
"""
extends Node

signal state_changed(current_state)

var states_map := {}

var states_stack := []
var current_state :Node= null
export(bool) var active := false setget set_active

func _ready()-> void:
	states_stack.push_front(get_child(0))
	current_state = states_stack[0]
	if active:
		start()

func start() -> void:
	current_state.enter()
	set_active(true)

func set_active(value:bool) -> void:
	active = value
	set_physics_process(value)
	set_process_input(value)
	if not active:
		states_stack = []
		current_state = null

func _unhandled_input(event :InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _physics_process(delta:float) -> void:
	current_state.update(delta)

func _on_animation_finished(anim_name:String) ->void:
	if not active:
		return
	current_state._on_animation_finished(anim_name)

func _change_state(state_name:String)->void:
	if not active:
		return
	current_state.exit()
	
	if state_name == "previous":
		states_stack.pop_front()
	else:
		states_stack[0] = states_map[state_name]
	
	current_state = states_stack[0]
	emit_signal("state_changed", current_state)
	current_state.enter()
