#warning-ignore-all:unused_class_variable
extends "res://enemies/CopBase.gd"

signal spawned

const PoliceMan = preload("res://enemies/polceman/PoliceMan.tscn")

export(float) var SPEED := 200
export(float) var VISION := 5
export(int) var WAIT_TIME := 30
#export(int)	var MASS := 1.0
#export(int)	var ARRIVE_DISTANCE := 10.0

enum STATES { IDLE, WALKING }

var path = []
var target_point_world = Vector2()
var target_position = Vector2()
#
#var velocity = Vector2()

var Map :Node
onready var MapAstar :Node = get_tree().get_nodes_in_group("MapAstar")[0]

func _ready()->void:
	state = STATES.IDLE

func on_error(new_error:int)->void:
	new_error = error
	if error != OK:
		print("Error in CopCar :", error)

func initialize( _map :Node) -> void:
	Map = _map
	self.error = $IdleTimer.connect("timeout",self,"_on_IdleTimer_timeout")
	self.error - MapAstar.connect('astar_complete',self,'astar_complete')
	
func astar_complete()->void:
	change_state(STATES.WALKING)

func change_state(new_state) -> void:
	if (new_state == state):
		return
	if new_state == STATES.IDLE:
		$IdleTimer.start(randi() % WAIT_TIME)
	elif new_state == STATES.WALKING:
		get_new_target()
		path = MapAstar.get_new_path(position, target_position)
		if not path or len(path) == 1:
			change_state(STATES.IDLE)
			return
		target_point_world = path[1] #set target as next point in line as we are at path[0] now
	state = new_state

#func cop_is_done(cop : Node):
#	cop.queue_free()
#	_change_state(STATES.IDLE)

func _physics_process(delta) -> void:
	if state != STATES.WALKING:
		return
	move_to(target_point_world, delta)
	if is_arrived(target_point_world):
		path.remove(0)
		if len(path) == 0:
			change_state(STATES.IDLE)
			return
		target_point_world = path[0]

func get_new_target() -> void:
	path.clear()
	target_point_world = null
	#if not on a valid tile move back to dispatch
	if not is_pos_valid(position):
		position = MapAstar.get_next_pos()
	#get new desination
	target_position = MapAstar.get_next_pos()
	visible = true

func move_to(world_position: Vector2, delta: float) -> void:
	var desired_velocity = (world_position - position).normalized() * SPEED * delta
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	if move_and_collide(velocity, false):
		change_state(STATES.IDLE)
	
func is_arrived(world_position:Vector2) -> bool:
	return position.distance_to(world_position) < ARRIVE_DISTANCE

func is_pos_valid(pos) ->bool:
	return Map.world_to_map(pos) in MapAstar.walkable_cells_list

func _on_IdleTimer_timeout() ->void:
		change_state(STATES.WALKING)
