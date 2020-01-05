# warning-ignore-all:unused_class_variable
extends "res://actors/NPC/npc.gd"

export(float) var SPEED := 150
#export(float) var VISION := 5
export(int) var WAIT_TIME := 5.0
export(int)	var MASS := 1.0
export(int)	var ARRIVE_DISTANCE := 10.0

enum STATES { IDLE=0, WAIT, GOING_HOME, GOING_WORK,GOING_SHOP }
var _state = STATES.IDLE

var path = []
var next_target_in_path = Vector2()
var target_position = Vector2()

var velocity = Vector2()

onready var wallet :Node= $DonationDesider/Wallet
onready var ROADS :Node= get_tree().get_nodes_in_group("Roads")[0]
onready var DISPATCH :Node= get_parent().get_parent()
onready var FowardVision :Node= $VisionPivot
onready var DonationDesider :Node= $DonationDesider

var home_pos : Vector2
var work_pos : Vector2

func initialize(_home:Vector2,_work:Vector2,_roads:Node= ROADS, _dispatch:Node = DISPATCH) -> void:
	home_pos = _home
	work_pos = _work
	ROADS = _roads
	DISPATCH = _dispatch
	position = ROADS.map_to_world(home_pos)
	target_position = position
	next_target_in_path = position
	if not FowardVision:
		FowardVision = get_node("VisionPivot")
	FowardVision.set_active(false)
	_change_state(STATES.GOING_WORK)

func _change_state(new_state) -> void:
	if (new_state == _state):
		return
	if new_state == STATES.IDLE:
		path.clear()
#		visible = true
#		$BumberSpace.disabled = true
		FowardVision.set_active(false)
	if new_state == STATES.GOING_HOME:
		set_path(home_pos)
		visible = true
#		$BumberSpace.disabled = false
		FowardVision.set_active(true)
	if new_state == STATES.GOING_WORK:
		set_path(work_pos)
		visible = true
#		$BumberSpace.disabled = false
		FowardVision.set_active(true)
	if new_state == STATES.WAIT:
		FowardVision.set_active(true)
		yield(get_tree().create_timer(WAIT_TIME), "timeout")
		new_state = _state #become previous state
	_state = new_state

func set_path(new_target_pos:Vector2) -> void:
		recenter_on_cell(target_position)
		set_new_target(ROADS.map_to_world(new_target_pos))
		path = DISPATCH.get_new_path(position, ROADS.map_to_world(new_target_pos))
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		next_target_in_path = path[1] #set target as next point in line as we are at path[0] now

func _physics_process(_delta:float) -> void:
	if _state != STATES.GOING_HOME:
		if _state != STATES.GOING_WORK:
			return
	if is_arrived(next_target_in_path):
		if len(path) == 0:
			return
		path.remove(0)
		if len(path) == 0:
			_change_state(STATES.IDLE)
			return
		next_target_in_path = path[0]
	move_to(next_target_in_path)
	update_angle()

func recenter_on_cell(center) ->void:
	position = ROADS.map_to_world(ROADS.world_to_map(center))
	if not is_pos_valid(position):
		position = ROADS.world_to_map(home_pos)

func set_new_target(new_target) -> void:
	path.clear()
	target_position = new_target

func move_to(world_position: Vector2) -> void:
	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	if move_and_slide(velocity):
		traffic()
	
func update_angle() ->void:
	var angle = velocity.angle()
	$VisionPivot.rotation = angle
	$AnimatedSprite.frame = get_next_frame(int(rad2deg(angle)))
	
func get_next_frame(check_angle:int) -> int:
	var frame : int = 5
	if check_angle < 180 and check_angle > 90:
		frame = 5
	elif check_angle < 90 and check_angle > 0:
		frame = 28
	elif check_angle < 0 and check_angle > -90:
		frame = 22
	elif check_angle < -90 and check_angle > -180:
		frame = 12
	return frame

func is_arrived(world_position:Vector2) -> bool:
	return position.distance_to(world_position) < ARRIVE_DISTANCE

func is_pos_valid(pos):
	return ROADS.world_to_map(pos) in DISPATCH.walkable_cells_list

func get_wallet() -> Node:
	return wallet
	
func donate(body:Node) -> void:
	var amount :int= DonationDesider.donate(body)
	speak("Here you go\n" + String(amount) + " coins" )
	yield(get_tree().create_timer(1), "timeout")
	speak('')

func traffic():
	pass
