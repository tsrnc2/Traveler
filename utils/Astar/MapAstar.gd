extends Node

signal astar_complete

var _is_ready : bool = false

export(Vector2) var DEFAULT_LOCATION := Vector2(13,93)

var map_limits : Rect2

var astar_node : AStar

var path_start_position := Vector2() setget _set_path_start_position
var path_end_position := Vector2() setget _set_path_end_position

var walkable_cells_list := []

var MAP : Node

func initialize(_map:Node) -> void:
	randomize()
	MAP = _map
	#	CELL_CENTER_OFFSET = Vector2(ROADS.get_cell_size().x / 4, -1 * (ROADS.get_cell_size().y / 4))
	map_limits = MAP.get_map_limits()
	astar_node = AStar.new()
	walkable_cells_list = MAP.get_walkable_cells()
	astar_add_walkable_cells(walkable_cells_list)
	astar_connect_walkable_cells(walkable_cells_list)
	emit_signal("astar_complete")
	_is_ready = true

func is_ready()-> bool:
	return _is_ready

func get_map()->Node:
	return MAP

func calculate_point_index(point:Vector2) -> float:
	point -= map_limits.position
	return point.y * map_limits.size.x + point.x

func set_default_location(loc : Vector2 = DEFAULT_LOCATION) -> void:
	DEFAULT_LOCATION = loc
	
func _get_valid_cell() -> Vector2:
	randomize()
	#pick a valid tile at random
	var random_location = randi() % (walkable_cells_list.size()-1)
	return walkable_cells_list[random_location]

func get_next_pos() -> Vector2:
	return MAP.map_to_world(_get_valid_cell())

# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells(cells_list) -> void:
	var point_index
	for point in cells_list:
		point_index = calculate_point_index(point)
		astar_node.add_point(point_index, Vector3(point.x, point.y, 1))

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
			Vector2(point.x, point.y - 1),
			Vector2(point.x + 1, point.y + 1),
			Vector2(point.x - 1, point.y - 1),
			Vector2(point.x + 1, point.y - 1),
			Vector2(point.x - 1, point.y + 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if not astar_node.has_point(point_relative_index):
				continue
			astar_node.connect_points(point_index, point_relative_index, false)
#
## This is a variation of the method above
## It connects cells horizontally, vertically AND diagonally
#func astar_connect_walkable_cells(points_array):
#	for point in points_array:
#		var point_index = calculate_point_index(point)
#		for local_y in range(3):
#			for local_x in range(3):
#				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
#				var point_relative_index = calculate_point_index(point_relative)
#				if point_relative == point or is_outside_map_bounds(point_relative):
#					continue
#				if not astar_node.has_point(point_relative_index):
#					continue
#				astar_node.connect_points(point_index, point_relative_index, true)

func is_outside_map_bounds(point:Vector2)->bool:
	if point.x < map_limits.position.x or point.y < map_limits.position.y or point.x < map_limits.end.x or point.y > map_limits.position.y:
		return true
	return false

func get_new_path(world_start, world_end)->Array:
	self.path_start_position = MAP.world_to_map(world_start)
	self.path_end_position = MAP.world_to_map(world_end)
	var _point_path =_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = MAP.map_to_world(Vector2(point.x, point.y))
		path_world.append(point_world)
	if path_world.size() == 0:
		print("error in MAPASTAR get_new_path")
		print("start position", path_start_position)
		print("end position", path_end_position)
	return path_world

func _recalculate_path() -> Array:
#	clear_previous_path_drawing()
	var _point_path = []
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	return _point_path

func _set_path_start_position(value:Vector2) ->void:
	if not value in walkable_cells_list:
		return
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
# warning-ignore:return_value_discarded
		_recalculate_path()

func _set_path_end_position(value:Vector2) ->void:
	if not value in walkable_cells_list:
		return
	path_end_position = value
	if path_start_position != value:
# warning-ignore:return_value_discarded
		_recalculate_path()
