extends TileMap

signal river_complete

var cell = preload("res://core/world/road/Points.tscn")

#export(Vector2) var tile_size := Vector2(82,41)  # size of a tile in the TileMap
export(float) var cull := 0.0  # chance to cull room
export(int) var river_size = 4 # number of squares for average river size
export(int) var variation = 2 # river size variation

var path : AStar # AStar pathfinding object

var points_positions := []
#
#onready var Ground := get_parent()

func initialize() -> void:
	randomize()
	print('loading water')
	path = AStar.new() # AStar pathfinding object
	make_points()
	cull_points()
	if path and points_positions:
		find_mst()
		make_map(path)
	$Waves.initialize(get_tree().get_nodes_in_group("weather")[0])
	emit_signal("river_complete")
	
func make_points() -> void:
	var used_cells = []
	used_cells = get_used_cells()
	if not used_cells:
		print("No water cells")
		return
	for pos in used_cells:
		var c = cell.instance()
		c.make_points(map_to_world(pos))
		$Points.add_child(c)
	
func cull_points() -> void:
	for point in $Points.get_children():
		if randf() < cull:
			point.queue_free()
		else:
			points_positions.append(Vector3(point.position.x, point.position.y, 0))
	

func find_mst() -> void:
	# Prim's algorithm
	# Given an array of positions (nodes), generates a minimum spanning tree 
	
	# add the first point
	path.add_point(path.get_available_point_id(), points_positions.pop_front())
	# Repeat until no more nodes remain
	while points_positions:
		var min_dist = INF  # Minimum distance so far
		var min_point = null  # Position of that node
		var point = null  # Current position
		# Loop through points in path
		for point1 in path.get_points():
			point1 = path.get_point_position(point1)
			# Loop through the remaining nodes
			for point2 in points_positions:
				# If the node is closer, make it the closest
				if point1.distance_to(point2) < min_dist:
					min_dist = point1.distance_to(point2)
					min_point = point2
					point = point1
		# Insert the resulting node into the path and add its connection
		var next_point = path.get_available_point_id()
		path.add_point(next_point, min_point)
		path.connect_points(path.get_closest_point(point), next_point)
		# Remove the node from the array
		points_positions.erase(min_point)

func make_map(new_path:AStar) -> void:
	# Carve rivers
	var connections = []  # One corridor per connection
	var path_size = get_path_size()
	for cell in $Points.get_children():
		set_cellv( world_to_map( Vector2( cell.position.x, cell.position.y) ), 0)
		# Carve connecting corridor
		var p = new_path.get_closest_point(Vector3(cell.position.x, cell.position.y, 0))
		for conn in new_path.get_point_connections(p):
			if not conn in connections:
				var start = world_to_map(Vector2(new_path.get_point_position(p).x, new_path.get_point_position(p).y))
				var end = world_to_map(Vector2(new_path.get_point_position(conn).x, new_path.get_point_position(conn).y))
				path = new_path
				path_size = get_path_size(path_size)
				carve_path(start, end, path_size)
		connections.append(p)
	update_bitmask_region()
	$Points.queue_free()

func get_path_size(_path_size:int = river_size) -> int:
	#pick a random size + or minus 1 within variation
	_path_size += pow( -1, (randi() % 2) )
	if _path_size > river_size + variation:
		_path_size = river_size + variation
	elif _path_size < river_size - variation:
		_path_size = river_size - variation
	return _path_size

func carve_path(pos1:Vector2, pos2:Vector2,path_size:int = river_size) -> void:
	# Carve a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	# choose either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	var is_every_other := true
	for x in range(pos1.x, pos2.x, x_diff):
#		set_cell(x, x_y.y, 0)
#		set_cell(x, x_y.y + y_diff, 0)  # widen the corridor
		if is_every_other:
			path_size = get_path_size(path_size)
		for multipler_offset in range(path_size):
# warning-ignore:integer_division
			set_cell(x, x_y.y + (multipler_offset * y_diff) - path_size/2, 0)
# warning-ignore:integer_division
			$Waves.set_cell(x, x_y.y + (multipler_offset * y_diff) - path_size/2, 4)
		is_every_other = !(is_every_other)
	for y in range(pos1.y, pos2.y, y_diff):
#		set_cell(y_x.x, y, 0)
#		set_cell(y_x.x + x_diff, y, 0)
		#random size path between path_size and variation
		if is_every_other:
			path_size = get_path_size(path_size)
		for multipler_offset in range(path_size):
# warning-ignore:integer_division
			set_cell(y_x.x + (multipler_offset * x_diff)-path_size/2, y, 0)
# warning-ignore:integer_division
			$Waves.set_cell(y_x.x + (multipler_offset * x_diff)-path_size/2, y, 4)
		is_every_other = !(is_every_other)
