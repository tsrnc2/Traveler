extends "res://utils/state/State.gd"

func enter():
	owner.set_dead(true)
	owner.get_node("AnimationPlayer").play("die")

func _on_animation_finished(_anim_name):
	emit_signal("finished", "none")
