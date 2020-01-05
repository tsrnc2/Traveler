extends Path2D

signal TrainEvent

export(int) var TRAIN_HOUR := 6
export(bool) var TRAIN_PAST_NOON := false

export(float) var STATION_POSITION := 0.5

export(float) var TIME_TO_STATION := 30.0 # seconds to get to station
export(float) var WAIT_TIME := 45.0 #seconds at station
export(float) var TIME_TO_LEAVE := 45.0 #seconds to leave town

onready var tween := $Tween
onready var train_position := $TrainPosition
onready var train := Node

var gameclock : Node

enum STATES {OFF_SCREEN,IDLE,COMING,GOING}

var state : int = STATES.OFF_SCREEN

var error :int =OK setget on_error

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("Error in TrainRoute :", error)

func initialize(new_hour:int = TRAIN_HOUR) ->void:
	print("Loading Train Route")
	TRAIN_HOUR = new_hour
	gameclock = get_tree().get_nodes_in_group("clock")[0]
	train = get_tree().get_nodes_in_group("train")[0]
	self.error = gameclock.connect("hour_update", self , "is_train_time")
	for train in get_tree().get_nodes_in_group("train"):
		train.initialize()
	
func is_train_time(hour:int, is_past_noon:bool)->void:
	if hour == TRAIN_HOUR and is_past_noon == TRAIN_PAST_NOON:
		emit_signal("TrainEvent")
		change_state(STATES.COMING)
		
func change_state(new_state:int)->void:
	if new_state == state:
		return
	state = new_state
	match state:
		STATES.OFF_SCREEN:
			visible = false
			train.set_is_moving(false)
		STATES.IDLE:
			train.set_is_moving(false)
			yield(get_tree().create_timer(WAIT_TIME),"timeout")
			change_state(STATES.GOING)
		STATES.COMING:
			train.set_is_moving(true)
			tween.interpolate_property(train_position,"unit_offset", 0 , STATION_POSITION, TIME_TO_STATION, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.start()
			yield(tween,"tween_completed")
			change_state(STATES.IDLE)
		STATES.GOING:
			train.set_is_moving(true)
			tween.interpolate_property(train_position,"unit_offset", STATION_POSITION , 1.0,TIME_TO_LEAVE, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
			yield(tween,"tween_completed")
			change_state(STATES.OFF_SCREEN)
			
