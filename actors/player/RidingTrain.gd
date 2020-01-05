extends "res://utils/state/State.gd"

var boarding_point : Position2D

func set_boarding_point(new_boarding_point:Position2D)->void:
	boarding_point = new_boarding_point

func enter()->void:
	if !boarding_point:
		print("Error in PlayerState RidingTrain: no boarding point set")

func update(_delta)->void:
	owner.global_position = boarding_point.global_position
	owner.emit_signal("position_changed", owner.global_position)

func _on_animation_finished(_previous_state:String) ->void:
	pass
