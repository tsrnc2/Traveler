extends ColorRect

signal parts_of_day

onready var InfoHUD = get_tree().get_nodes_in_group("InfoHUD")[0]

enum NIGHTCYCLE {
	MORNING = 0,
	DAY = 1,
	NIGHT =2
}

var state :int setget set_state

var is_flashlight : bool = false

export(Color) var MORNING_COLOR := Color("80000000")
export(Color) var DAY_COLOR := Color("00000000")
export(Color) var NIGHT_COLOR := Color("C8000000")
export(Color) var MESSAGE_COLOR := Color("F0F0F000")
export(Color) var FLASHLIGHT_COLOR := Color('65f2df0d')

export var MORNING_HOUR = 6
export var EVENING_HOUR = 20 # military time

onready var tween : Tween

var error :int = OK setget on_error

func on_error(new_error)->void:
	new_error = error
	if error != OK:
		print("Error in WorldTimeOfDay :", error)

func _init()->void:
	tween = Tween.new()
	add_child(tween)

func initialize(GameClock: Node = $"../../GameClock", is_visable: bool = true) -> void:
	print('loading Sun')
	assert(InfoHUD is Node)
	self.error = GameClock.connect("hour_update", self, "new_time_of_day")
	visible = is_visable
	
func new_time_of_day(hour:int, is_past_noon:bool) -> void:
	if is_past_noon:
		hour += 12
	if hour < MORNING_HOUR:
		self.state = NIGHTCYCLE.MORNING
	elif hour < EVENING_HOUR:
		self.state = NIGHTCYCLE.DAY
	else:
		self.state = NIGHTCYCLE.NIGHT

func set_state(new_state :int,force := false) -> void:
	if new_state == state and not force:
		return
	if new_state != NIGHTCYCLE.DAY:
		show()
	var new_color : Color
	if new_state == NIGHTCYCLE.MORNING:
		InfoHUD.display("Morning Time\n The best time to catch people on their way to work.",MESSAGE_COLOR)
		new_color = MORNING_COLOR
		if is_flashlight:
			new_color = FLASHLIGHT_COLOR
		emit_signal("parts_of_day",NIGHTCYCLE.MORNING)
	elif new_state == NIGHTCYCLE.DAY:
		new_color = DAY_COLOR
		emit_signal("parts_of_day",NIGHTCYCLE.DAY)
	else:
		new_color = NIGHT_COLOR
		InfoHUD.display("Night Time\n Have a way to stay warm.",MESSAGE_COLOR)
		emit_signal("parts_of_day",NIGHTCYCLE.NIGHT)
		if is_flashlight:
			new_color = FLASHLIGHT_COLOR
	state = new_state
	self.error = not tween.interpolate_property(self, "color", get_frame_color(), new_color, 8.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	self.error = not tween.start()

func get_frame_color()->Color:
	return color

func set_frame_color(new_color):
	if color == DAY_COLOR:
		hide()
	else:
		show()
	color = new_color
	
func toggle_flashlight(is_on:bool)->void:
	is_flashlight = is_on
	set_state(state,true)
