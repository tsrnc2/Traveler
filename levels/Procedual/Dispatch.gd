extends Node
signal cops_complete
signal astar_complete

export(int) var NUM_OF_COPS := 20
export(PackedScene) var COP := preload("res://actors/cops/copcar.tscn")
export(Vector2) var DEFAULT_LOCATION := Vector2(75,62)
export(Vector2) var CELL_CENTER_OFFSET := Vector2(0,55)

var map_limits : Rect2

var location : Vector2

onready var ROADS :Node = get_tree().get_nodes_in_group("Roads")[0]

var astar_node : AStar
var TARGET : Node

var path_start_position := Vector2() setget _set_path_start_position
var path_end_position := Vector2() setget _set_path_end_position

var walkable_cells_list := []

func initialize( target :Node, _roads : Node = ROADS) -> void:
	ROADS = _roads
	TARGET = target
#	CELL_CENTER_OFFSET = Vector2( int((ROADS.cell_size.x)/2) ,0 )
	map_limits = ROADS.get_used_rect()
	astar_node = AStar.new()
	walkable_cells_list = ROADS.get_used_cells()
	astar_add_walkable_cells(walkable_cells_list)
	astar_connect_walkable_cells(walkable_cells_list)
	set_dispatch_location(DEFAULT_LOCATION)
	emit_signal("astar_complete")
	load_cops()

func calculate_point_index(point:Vector2) -> float:
	point -= map_limits.position
	return point.y * map_limits.size.x + point.x

func load_cops() -> void:
	print("loading cops")
	for i in NUM_OF_COPS:
		var new_cop = COP.instance()
		add_child(new_cop)
		new_cop.initialize(TARGET, ROADS)
	emit_signal("cops_complete")

func get_dispatch_location() -> Vector2:
	return ROADS.map_to_world(location)

func set_dispatch_location(loc : Vector2 = DEFAULT_LOCATION) -> void:
	location = loc
	
func _get_valid_cell() -> Vector2:
	randomize()
	#pick a valid tile at random
	var random_location = randi() % walkable_cells_list.size()
	return walkable_cells_list[random_location]

func get_next_pos() -> Vector2:
	return ROADS.map_to_world(_get_valid_cell())

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
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if not astar_node.has_point(point_relative_index):
				continue
			astar_node.connect_points(point_index, point_relative_index, false)
#
## This is a variation of the method above
## It connects cells horizontally, vertically AND diagonally
#func astar_connect_walkable_cells_diagonal(points_array):
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

func get_new_path(world_start, world_end):
	self.path_start_position = ROADS.world_to_map(world_start)
	self.path_end_position = ROADS.world_to_map(world_end)
	var _point_path =_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = ROADS.map_to_world(Vector2(point.x, point.y))
		path_world.append(point_world + CELL_CENTER_OFFSET)
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

	
