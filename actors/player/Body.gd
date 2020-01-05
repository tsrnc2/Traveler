extends AnimatedSprite

var DIRECTION :Dictionary = { \
				'NE' : Vector2(2,-1).normalized(),
				'E' : Vector2(2,0).normalized(),
				'SE' : Vector2(2,1).normalized(),
				'S' : Vector2(0,1),
				'SW' : Vector2(-2,1).normalized(),
				'W' : Vector2(-2,0).normalized(),
				'NW' : Vector2(-2,-1).normalized(),
				'N' : Vector2(0,-1),
}


#direction_number is 0-7 . Zero is NE increasing clockwise.
var last_direction_number = 0
var last_direction = Vector2(1,0)
var curr_animation = "idle"

func idle():
	curr_animation = "idle"
	_play_animation(curr_animation,last_direction_number)
	
func run():
	curr_animation = "run"
	_play_animation(curr_animation,last_direction_number)

func pickup():
	curr_animation = "pickup"
	_play_animation(curr_animation,last_direction_number)
	
func duck():
	curr_animation = "duck"
	_play_animation(curr_animation,last_direction_number)
	
func ducking():
	curr_animation = "ducking"
	_play_animation(curr_animation,2)

func stand_up():
	curr_animation = "standup"
	_play_animation(curr_animation,last_direction_number)

func _on_Player_direction_changed(new_direction:Vector2) ->void:
	var direction_number:int
	if new_direction == Vector2(0,0):
		new_direction = last_direction
	else:
		curr_animation = "run"
	match new_direction:
		DIRECTION.NE:
			direction_number = 0
		DIRECTION.E:
			direction_number = 1
		DIRECTION.SE:
			direction_number = 2 
		DIRECTION.S:
			direction_number = 3
		DIRECTION.SW:
			direction_number = 4
		DIRECTION.W:
			direction_number = 5
		DIRECTION.NW:
			direction_number = 6
		DIRECTION.N:
			direction_number = 7
	last_direction = new_direction
	last_direction_number = direction_number
	_play_animation(curr_animation,direction_number)
	
func _play_animation(animation_name:String, direction:int) ->void:
	self.play(animation_name + String(direction))

func _on_StateMachine_state_changed(current_state:Node) -> void:
	if current_state.name == curr_animation:
		return
	match current_state.name:
		"Idle":
			idle()
		"Move":
			run()
		"Pickup":
			pickup()
		"Jump":
			idle()
		"BoardTrain":
			duck()
		"RideTrain":
			ducking()
		"DepartTrain":
			stand_up()
		_:
			print("Error in Player Body Sprite: No matching anination found for state: " + current_state.name)
