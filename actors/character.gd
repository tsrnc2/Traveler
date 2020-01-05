extends Position2D

export(float) var SPEED = 100.0
export(float) var VISION = 5
export(int) var WAIT_TIME = 30

enum STATES { IDLE, PATROL, ONCALL }
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()

var velocity = Vector2()

onready var TileMap = get_parent().get_parent().get_node('Road')

func initialize():
	print('Initialized')
	_change_state(STATES.IDLE)

func _change_state(new_state):
	print('New State: '+String(new_state))
	if new_state == _state:
		return
	if new_state == STATES.IDLE:
		#wait up to WAIT_TIME when idle
		$IdleTimer.start(randi()%WAIT_TIME)
	if new_state == STATES.PATROL:
		reset()
		path = TileMap._get_path(position, target_position)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		target_point_world = path[1]
	_state = new_state


func _process(_delta):
	if _state == STATES.IDLE:
		return
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
			_change_state(STATES.IDLE)
			return
		target_point_world = path[0]

func reset():
	randomize()
	print('Reset')
	#if not on a valid tile move to a random valid tile
	global_position = TileMap.map_to_world(TileMap.world_to_map(target_position))
	if is_pos_valid(global_position):
		print('Not Valid Location')
		global_position = TileMap._get_next_pos()
	path = null
	target_point_world = null
	target_position = TileMap._get_next_pos()

func move_to(world_position):
	var MASS = 1.0
	var ARRIVE_DISTANCE = 10.0

	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	position += velocity * get_process_delta_time()
	$VisionPivot.rotation = velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE

func is_pos_valid(pos):
	return not TileMap.world_to_map(pos) in TileMap.walkable_cells_list

func _on_IdleTimer_timeout():
		_change_state(STATES.PATROL)
