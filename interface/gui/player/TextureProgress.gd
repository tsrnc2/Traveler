extends TextureProgress

export(Color) var COLOR_FULL : Color
export(Color) var COLOR_NORMAL: Color
export(Color) var COLOR_LOW: Color
export(Color) var COLOR_CRITICAL: Color
export(Color) var COLOR_REGENARATION: Color

export(float, 0, 1) var THRESHOLD_LOW := 0.3
export(float, 0, 1) var THRESHOLD_CRITICAL := 0.1

var color_active :Color= COLOR_NORMAL

var tween_error := false setget on_tween_error

onready var tween = $Tween

onready var start_pos:Vector2= rect_position
var bounce_lock := false

func on_tween_error(new_error):
	tween_error = new_error
	if not tween_error:
		print ("Error in TextureProgress Bar Tweens")

func _on_Bar_maximum_changed(maximum:int) ->void:
	max_value = maximum

func animate_size_and_bounce(percent_increase:float,_height:int) ->void:
	if bounce_lock:
		return
	bounce_lock = true
	var start_size : = Vector2(1,1)
	var end_size : Vector2
	if percent_increase != 1.0:
		end_size = Vector2(start_size.x * percent_increase, start_size.y * (percent_increase/2))
	else:
		end_size = start_size
	self.tween_error = tween.interpolate_property(self, "rect_scale", start_size, end_size, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.interpolate_property(self, "rect_position", start_pos, start_pos +Vector2(-_height/2.0,-_height), 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.start()
	yield(tween,"tween_all_completed")
	self.tween_error = tween.interpolate_property(self, "rect_scale", end_size, start_size, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.interpolate_property(self, "rect_position", start_pos +Vector2(-_height/2.0,-_height), start_pos, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.start()	
	yield(tween,"tween_all_completed")
	bounce_lock = false

func animate_value(start:int, end:int) ->void:
	self.tween_error = tween.interpolate_property(self, "value", start, end, 0.5, Tween.TRANS_QUART, Tween.EASE_OUT)
	self.tween_error = tween.start()

func update_color(new_value,is_regenerating = false):
	if is_regenerating:
		color_active = COLOR_REGENARATION
		return
	var new_color
	if new_value > THRESHOLD_LOW * max_value:
		if new_value < max_value:
			new_color = COLOR_NORMAL
		else:
			new_color = COLOR_FULL
	elif new_value > THRESHOLD_CRITICAL * max_value:
		new_color = COLOR_LOW
	else:
		new_color = COLOR_CRITICAL

	if new_color == color_active:
		return
	color_active = new_color
	self.tween_error = tween.interpolate_property(self, "modulate", modulate, new_color, 0.4, Tween.TRANS_QUART, Tween.EASE_OUT)
	self.tween_error = tween.start()
