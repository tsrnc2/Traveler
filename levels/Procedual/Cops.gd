extends Node
signal astar_complete
signal cops_complete

export(int) var NUM_OF_COPS := 20
export(PackedScene) var COP := preload("res://actors/cop.tscn")

var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var map_limits : Rect2

var ROADS = "../Roads"

var walkable_cells_list = []

var _point_path = []

onready var astar_node = AStar.new()

func initialize(_roads :TileMap = ROADS) -> void:
	ROADS = _roads
	print('loading path finding')
	var map_limits = ROADS.get_used_rect()
	walkable_cells_list = ROADS.get_used_cells()
	assert(walkable_cells_list.size() > 0)
	walkable_cells_list = astar_add_walkable_cells()
	astar_connect_walkable_cells(walkable_cells_list)
	emit_signal("astar_complete")
	
	print("loading cops")
	for i in NUM_OF_COPS:
		var new_cop = COP.instance()
#		new_cop.initialize(_roads)
		add_child(new_cop)
	emit_signal("cops_complete")
	
func _get_valid_cell() -> Array:
	randomize()
	#pick a valid tile at random from availbe tiles
	assert(walkable_cells_list.size() > 0)
	var random_location = randi() % walkable_cells_list.size()
	return walkable_cells_list[random_location]

func get_next_pos() -> Vector2:
	var cell = _get_valid_cell()
	return ROADS.map_to_world(cell)
	
func astar_add_walkable_cells() -> Array:
	var points_array = []
	for y in range(map_limits.position.y, map_limits.size.y, 1):
		for x in range(map_limits.position.y, map_limits.size.x, 1):
			var point = Vector2(x, y)
			if not point in walkable_cells_list:
				continue
			points_array.append(point)
			# The AStar class references points with indices
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s
			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array

func astar_connect_walkable_cells(points_array) -> void:
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce,
		# We connect the current point with it
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A
			# If you set this value to false, it becomes a one-way path
			# As we loop through all points we can set it to false
			astar_node.connect_points(point_index, point_relative_index, false)

# This is a variation of the method above
# It connects cells horizontally, vertically AND diagonally
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)

				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)

func is_outside_map_bounds(point:Vector2) -> bool:
	return point.x < 0 or point.y < 0 or point.x >= map_limits.size.x or point.y >= map_limits.size.y

func calculate_point_index(point:Vector2) -> float:
	point -= map_limits.position
	return point.y * map_limits.size.x + point.x
#	return point.x + map_size.x * point.y

func _get_path(world_start : Vector2, world_end : Vector2) -> Array:
	self.path_start_position = ROADS.world_to_map(world_start)
	self.path_end_position = ROADS.world_to_map(world_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = ROADS.map_to_world(Vector2(point.x, point.y))
		path_world.append(point_world)
	return path_world

func _recalculate_path() -> void:
#	clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)

# Setters for the start and end path values.
func _set_path_start_position(value) -> void:
	if not value in walkable_cells_list:
		return
	if is_outside_map_bounds(value):
		return
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()

func _set_path_end_position(value) -> void:
	if not value in walkable_cells_list:
		return
	if is_outside_map_bounds(value):
		return
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()
