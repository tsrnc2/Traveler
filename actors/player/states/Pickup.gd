extends "res://utils/state/State.gd"

func enter()->void:
	owner.emit_signal("pickup",owner.global_position)
	owner.get_animation_player().play("pickup")

func _on_animation_finished(_previous_state:String) ->void:
	emit_signal("finished",  "idle")
