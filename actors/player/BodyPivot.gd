extends Position2D

func _input(event):
	look_at(get_global_mouse_position())