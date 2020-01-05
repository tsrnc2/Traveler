extends Node

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in AnimateBar :",self.name, " error code :", error)

var GROW_PERCENT := 1.0

func animate_bar(bar:Node, new_target_value:float, _force := false) -> void:
	if (bar.value - new_target_value > 5) or (bar.value < new_target_value) or _force:
		bar.animate_size_and_bounce(GROW_PERCENT,10)
	bar.animate_value(bar.value, new_target_value)
	bar.update_color(new_target_value)
