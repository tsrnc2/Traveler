extends Node

signal time_updated

export(float) var SECONDS_PER_MIN := 5.0

onready var Timer = $Timer

var day = 1
var hour := 12
var minute := 0
var is_past_noon : bool = false

func initialize():
	Timer.connect('timeout',self,'on_Timer_timeout')
	Timer.start(SECONDS_PER_MIN)

func add_1_min():
	minute = minute + 1
	if minute > 60:
		minute  = 0
		add_1_hour()

func add_1_hour():
	hour = hour + 1
	if hour > 12:
		hour = 0
		add_half_day()

func add_half_day():
	if is_past_noon:
		day = day + 1
	is_past_noon != is_past_noon

func ampm() -> String:
	if is_past_noon:
		return "PM"
	return "AM"
		
func on_Timer_timeout():
	add_1_min()
	emit_signal("time_updated", day, hour, minute, is_past_noon)
