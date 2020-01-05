# Collection of important methods to handle direction and animation
extends "res://utils/state/State.gd"

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_move_left") or Input.is_action_pressed("joy_move_left") \
	or event.is_action_pressed("player_move_right") or Input.is_action_pressed("joy_move_right") \
	or event.is_action_pressed("player_move_up") or Input.is_action_pressed("joy_move_up") \
	or event.is_action_pressed("player_move_down") or Input.is_action_pressed("joy_move_down"):
		get_tree().set_input_as_handled()

func get_input_direction():
	var input_direction = Vector2()
	input_direction.x = \
		int(Input.is_action_pressed("player_move_right") or Input.is_action_pressed("joy_move_right")) *2- \
		int(Input.is_action_pressed("player_move_left") or Input.is_action_pressed("joy_move_left")) *2
	input_direction.y = \
		int(Input.is_action_pressed("player_move_down") or Input.is_action_pressed("joy_move_down")) - \
		int(Input.is_action_pressed("player_move_up") or Input.is_action_pressed("joy_move_up"))
	return input_direction.normalized()

func update_move_direction(direction : Vector2) -> void:
	if direction and owner.look_direction != direction:
		owner.look_direction = direction
