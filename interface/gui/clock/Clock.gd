extends Control

onready var Label = $Label

var error :int = OK setget on_error

func on_error(new_error) -> void:
	error = new_error
	print("Error in ClockHUD :", error)

func initialize(GameClock: Node) -> void:
	error = GameClock.connect('time_updated', self, 'display_clock')

func display_clock(_day:int = 0, hour:int= 7, minute:int = 30, is_past_noon:bool = false) ->void:
	if minute < 10:
		Label.text = str(hour) + ":0" + str(minute) + ' ' + ampm(is_past_noon)
	else:
		Label.text = str(hour) + ":" + str(minute) + ' ' + ampm(is_past_noon)

func ampm(is_past_noon:bool) -> String:
	if is_past_noon:
		return "PM"
	return "AM"
	
