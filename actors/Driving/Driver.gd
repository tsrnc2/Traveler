extends Area2D

enum STATE {WAIT, CONTINUE}
enum DIRECTION {NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NOTHWEST}

var direction : int
var is_delayed := false
var state :int = STATE.CONTINUE

func initialize() -> void:
	connect("body_entered",self,"on_body_entered()")

func on_body_entered(body:Node) ->void:
	if body.is_in_group("stopsign"):
		register_turn(body)
		change_state(STATE.WAIT)
	if body.is_in_group("vehicle"):
		if is_traveling_same_direction(body):
			if is_in_front(body.global_position):
				change_state(STATE.CONTINUE)
			change_state(STATE.WAIT)
			return
		elif is_delayed:
			change_state(STATE.WAIT)
			return
		set_colliding_body_delayed(body)
		return

func change_state(new_state:int) -> void:
	match new_state:
		STATE.CONTINUE:
			is_delayed = false
	state = new_state
	
func register_turn(body:Node) ->void:
	body.register_turn(self)
	
func is_traveling_same_direction(body) -> bool:
	return body.direction == direction
	
func set_colliding_body_delayed(body) -> void:
	body.is_delayed = true
	
func is_in_front(location:Vector2) -> bool:
	match direction:
		DIRECTION.NORTH:
			if global_position.x > location.x:
				return true
		DIRECTION.EAST:
			if global_position.y > location.y:
				return true
		DIRECTION.SOUTH:
			if global_position.x < location.x:
				return true
		DIRECTION.WEST:
			if global_position.y < location.y:
				return true
	return false
