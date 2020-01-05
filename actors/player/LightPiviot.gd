extends Position2D

func _on_Player_direction_changed(new_direction):
	rotation = new_direction.angle()
