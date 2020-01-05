extends Node
signal astar_complete
signal cops_complete
#
export(int) var NUM_OF_COPS := 20
export(PackedScene) var COP := preload("res://actors/cop.tscn")
var map_limits : Rect2
#
onready var ROADS = $"../Roads"

var astar_node : AStar

var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

# get_used_cells_by_id is a method from the TileMap node
# here the id 0 corresponds to the grey tile, the obstacles
var walkable_cells_list = []
export var _cell_offset = Vector2(10,10)
var map_offset : Vector2

func initialize( _roads : Node = ROADS) -> void:
	ROADS = _roads
	map_limits = ROADS.get_used_rect()
	map_offset = Vector2(int((map_limits.size.x/ROADS.cell_size.x)/2), int((map_limits.size.y/ROADS.cell_size.y)/2))
	astar_node = AStar.new()
	
	for cell in ROADS.get_used_cells():
		walkable_cells_list.append(cell + map_offset)
#	walkable_cells_list = ROADS.get_used_cells()

	astar_add_walkable_cells(walkable_cells_list)
	astar_connect_walkable_cells(walkable_cells_list)
	
	load_cops()

func calculate_point_index(point:Vector2) -> float:
	point -= map_limits.position
	return point.y * map_limits.size.x + point.x


func load_cops() -> void:
	print("loading cops")
	for i in NUM_OF_COPS:
		var new_cop = COP.instance()
		new_cop.initialize(ROADS)
		add_child(new_cop)
	emit_signal("cops_complete")


func _get_valid_cell() -> Vector2:
	randomize()
	#pick a valid tile at random
	var random_location = randi() % walkable_cells_list.size()
	return walkable_cells_list[random_location]

func get_next_pos() -> Vector2:
	return ROADS.map_to_world(_get_valid_cell()) + _cell_offset

# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells(cells_list) -> void:
	var point_index
	for point in cells_list:
		point_index = calculate_point_index(point)
		astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
#	var points_array = []
#	for y in range(map_size.y):
#		for x in range(map_size.x):
#			var point = Vector2(x, y)
#			if not point in walkable_cells_list:
#				continue
#
#			points_array.append(point)
#			# The AStar class references points with indices
#			# Using a function to calculate the index from a point's coordinates
#			# ensures we always get the same index with the same input point
#			var point_index = calculate_point_index(point)
#			# AStar works for both 2d and 3d, so we have to convert the point
#			# coordinates from and to Vector3s
#			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
#	return points_array


# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
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


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_limits.size.x or point.y >= map_limits.size.y


func get_new_path(world_start, world_end):
	self.path_start_position = ROADS.world_to_map(world_start)
	self.path_end_position = ROADS.world_to_map(world_end)
	var _point_path =_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = ROADS.map_to_world(Vector2(point.x, point.y)) + _cell_offset
		path_world.append(point_world)
	return path_world


func _recalculate_path() -> Array:
#	clear_previous_path_drawing()
	var _point_path = []
	var start_point_index = calculate_point_index(path_start_position + map_offset)
	var end_point_index = calculate_point_index(path_end_position + map_offset)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	
	for point in astar_node.get_point_path(start_point_index, end_point_index):
		_point_path.append(point - map_offset)
	return _point_path

# Setters for the start and end path values.
func _set_path_start_position(value):
#	if not value in walkable_cells_list:
#		return
#	if is_outside_map_bounds(value):
#		return
#	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
#	if not value in walkable_cells_list:
#		return
#	if is_outside_map_bounds(value):
#		return
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()
