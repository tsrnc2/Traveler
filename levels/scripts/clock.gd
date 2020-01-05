extends Node

signal hour_update
signal quarter_hour_update
signal time_updated
signal new_day

export(float) var SECONDS_PER_MIN := 1.0

onready var Timer = $Timer

export(int) var day := 0
export(int) var hour := 7
export(int) var minute := 30
export(bool) var is_past_noon : bool = false

func initialize()->void:
	Timer.connect('timeout',self,'on_Timer_timeout')
	Timer.start(SECONDS_PER_MIN)

func add_1_min()->void:
	minute = minute + 1
	if minute >= 60:
		minute  = 0
		add_1_hour()
	if minute == 0 or minute == 15 or minute == 30 or minute == 45:
		emit_signal("quarter_hour_update")

func add_1_hour()->void:
	hour = hour + 1
	if hour > 12:
		hour = 0
		add_half_day()
	emit_signal("hour_update", hour, is_past_noon)

func add_half_day()->void:
	if is_past_noon:
		day = day + 1
		emit_signal("new_day",day)
	is_past_noon =  not is_past_noon

func ampm() -> String:
	if is_past_noon:
		return "PM"
	return "AM"
		
func on_Timer_timeout()->void:
	add_1_min()
	emit_signal("time_updated", day, hour, minute, is_past_noon)
