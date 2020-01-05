extends Node2D

signal animation()
signal combo_finished()

enum States { IDLE, PICKUP }
var state = null

enum InputStates { WAITING, LISTENING, REGISTERED }
var input_state = InputStates.WAITING
var ready_for_next_pickup = false
func _ready():
	$AnimationPlayer.connect('animation_finished', self, "_on_animation_finished")
	_change_state(States.IDLE)

func _change_state(new_state):
	match state:
		States.IDLE:
			visible = true
	match new_state:
		States.IDLE:
			visible = false
		States.PICKUP:
			input_state = InputStates.WAITING
			ready_for_next_pickup = false
	state = new_state

func _input(event):
	if not state == States.PICKUP:
		return
	if input_state != InputStates.LISTENING:
		return
	if event.is_action_pressed('pickup'):
		input_state = InputStates.REGISTERED

func _physics_process(delta):
	if input_state == InputStates.REGISTERED and ready_for_next_pickup:
		pickup()

func pickup():
	_change_state(States.PICKUP)

# use with AnimationPlayer func track
func set_attack_input_listening():
	input_state = InputStates.LISTENING

# use with AnimationPlayer func track
func set_ready_for_next_attack():
	ready_for_next_pickup = true

func _on_animation_finished(name):
	if input_state == InputStates.REGISTERED:
		pickup()
	else:
		_change_state(States.IDLE)
		emit_signal("pickup_complete")
