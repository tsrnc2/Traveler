extends Position2D

signal position_changed(new_postion)

var past_pos : Vector2

func set_active(is_active:bool)->void:
	set_process(is_active)

func _process(_delta):
	if global_position != past_pos:
		past_pos = global_position
		emit_signal('position_changed',global_position)
