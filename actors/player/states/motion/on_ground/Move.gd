extends "res://actors/player/states/motion/on_ground/OnGround.gd"

signal last_moved(direction)

export(float) var MAX_WALK_SPEED := 100.0
export(float) var MAX_RUN_SPEED := 140.0
export(int) var RUNNINGSTAMINACOST := 8.0

onready var Stamina  := get_node("../../Stamina")

const DustRun := preload("res://vfx/particles/dust_puffs/DustRun.tscn")
const DustWalk := preload("res://vfx/particles/dust_puffs/DustWalk.tscn")

func enter()->void:
	speed = 0.0
	velocity = Vector2()
	var input_direction = get_input_direction()
	update_move_direction(input_direction)
	owner.get_animation_player().play("walk")

func exit() ->void:
	owner.get_animation_player().play("idle")

func handle_input(event:InputEvent):
	return .handle_input(event)

func update(_delta) -> void:
	var input_direction = get_input_direction()
	if not input_direction:
		emit_signal("finished", "idle")
	update_move_direction(input_direction)
	speed = MAX_RUN_SPEED if is_time_to_run() else MAX_WALK_SPEED
	velocity = input_direction.normalized() * speed
	var collision_info = owner.move(velocity)
	if not collision_info:
		return
	if speed == MAX_RUN_SPEED and collision_info.collider.is_in_group("environment"):
		emit_signal("last_moved", input_direction)
		emit_signal("finished", 'bump')

func spawn_dust() -> void:
	var dust
	match speed:
		MAX_RUN_SPEED:
			dust = DustRun.instance()
		MAX_WALK_SPEED:
			dust = DustWalk.instance()
	owner.add_child(dust)
	dust.start()

func is_time_to_run() -> bool:
	if Input.is_action_pressed("player_run") and not Stamina.is_exhausted:
		start_running()
		return true
	return false
	
func start_running() -> void:
	if $RunTimer.is_stopped():
		Stamina.take_stamina(RUNNINGSTAMINACOST, "Running ")
		$RunTimer.start(0.25)

