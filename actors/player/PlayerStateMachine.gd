extends "res://utils/state/StateMachine.gd"

func _ready()-> void:
	states_map = {
		'idle': $Idle,
		'move': $Move,
		'jump': $Jump,
		'bump': $Bump,
		'fall': $Fall,
		'stagger': $Stagger,
		'pickup': $Pickup,
		'die': $Die,
		'boardtrain': $BoardTrain,
		'ridetrain': $RideTrain,
		'departtrain' : $DepartTrain
	}
	for state in get_children():
		state.connect('finished', self, '_change_state')

func _change_state(state_name:String) -> void:
	if not active:
		return
	if current_state == states_map['die']:
		set_active(false)
		return
	# Reset the player's jump height if transitioning away from jump to a state
	# that would stop jump's update method
	if current_state == states_map['jump'] and state_name in ['fall']:
		current_state.height = 0
	if state_name in ['stagger', 'jump']:
		states_stack.push_front(states_map[state_name])
	if state_name == 'jump' and current_state == $Move:
		$Jump.initialize($Move.speed, $Move.velocity)
	._change_state(state_name)

func _unhandled_input(event:InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func board_train(bording_point:Node,is_boarding:bool = false)->void:
	if not is_boarding:
		_change_state('departtrain')
		return
	states_map['boardtrain'].set_boarding_point(bording_point)
	states_map['ridetrain'].set_boarding_point(bording_point)
	_change_state('boardtrain')
