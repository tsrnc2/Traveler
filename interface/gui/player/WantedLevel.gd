extends Control

signal maximum_changed(maximum)
signal value_changed(value)

var maximum := 100
var current_wanted_level := 0

var error :int = OK setget on_error
var tween_error:bool = true setget on_tween_error

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("error in WantedLevelHUD :", error)

func on_tween_error(new_error:bool)->void:
	tween_error = new_error
	if tween_error != true:
		print("error in WantedLevelHUD tween:", tween_error)

var tween : Tween

func initialize(wanted_node:Node)->void:
	self.error = wanted_node.connect('wanted_level_changed', self, '_on_Player_wanted_level_changed')
	maximum = wanted_node.MAXWANTEDLEVEL
	current_wanted_level = wanted_node.wanted_level
	emit_signal("maximum_changed", maximum)
	emit_signal("value_changed",current_wanted_level)
	animate_bar(current_wanted_level)
	tween = Tween.new()
	add_child(tween)
	wanted_node.initialize()

func _on_Player_wanted_level_changed(new_wanted_level:int) ->void:
	animate_bar(new_wanted_level)
	current_wanted_level = new_wanted_level

func animate_bar(target_wanted_level:int)->void:
	$TextureProgress.animate_value(current_wanted_level, target_wanted_level)
	$TextureProgress.update_color(target_wanted_level)

func _on_TextureProgress_value_changed(value:int)->void:
	emit_signal("value_changed",value)

func animate_size(percent_increase:float) ->void:
	var start_size :Vector2= rect_size
	self.tween_error = tween.interpolate_property(self, "rect_size", start_size, start_size * percent_increase, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.start()
	yield(tween,"tween_all_completed")
	self.tween_error = tween.interpolate_property(self, "rect_size", start_size * percent_increase, start_size, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.start()

func bounce(_height:int)->void:
	var start_pos:Vector2= rect_position
	self.tween_error = tween.interpolate_property(self, "rect_position", start_pos, start_pos +Vector2(0,_height), 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.start()
	yield(tween,"tween_all_completed")
	self.tween_error = tween.interpolate_property(self, "rect_position", start_pos +Vector2(0,_height), start_pos, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.start()
