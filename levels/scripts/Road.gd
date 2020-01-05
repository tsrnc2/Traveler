extends TileMap

var Room = preload("res://core/world/road/Points.tscn")

export(int) var tile_size := 32  # size of a tile in the TileMap
export(int) var num_rooms := 50  # number of rooms to generate
export(int) var min_size := 6  # minimum room size (in tiles)
export(int) var max_size := 15  # maximum room size (in tiles)
export(int) var hspread := 400  # horizontal spread (in pixels)
export(float) var cull := 0.5  # chance to cull room
export(int) var river_size = 4 # number of squares for average river size
export(int) var variation = 2 # river size variation

var path : AStar # AStar pathfinding object
var start_room = null
var end_room = null
var play_mode = false  
var player = null


func initialize():
	randomize()
	clear()
	path = AStar.new() # AStar pathfinding object
	make_points(path)
	
func make_points(path:AStar) -> AStar:
	for i in range(num_rooms):
		var pos = Vector2(rand_range(-hspread, hspread), 0)
		var r = Room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_points(pos, Vector2(w, h) * tile_size)
		$Points.add_child(r)
	# wait for movement to stop
	yield(get_tree().create_timer(1.1), 'timeout')
	# cull rooms
	var points_positions = []
	for points in $Points.get_children():
		if randf() < cull:
			points.queue_free()
		else:
			points.mode = RigidBody2D.MODE_STATIC
			points_positions.append(Vector3(points.position.x, points.position.y, 0))
	yield(get_tree(), 'idle_frame')
	# generate a minimum spanning tree connecting the rooms
	path = find_mst(points_positions,path)
	if path:
		make_map(path)
	return path

func _process(delta):
	update()
	var firstmap := true

func find_mst(nodes,path:AStar) -> AStar:
	# Prim's algorithm
	# Given an array of positions (nodes), generates a minimum
	# spanning tree
	# Returns an AStar object
	
	# Initialize the AStar and add the first point
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	# Repeat until no more nodes remain
	while nodes:
		var min_dist = INF  # Minimum distance so far
		var min_point = null  # Position of that node
		var point = null  # Current position
		# Loop through points in path
		for point1 in path.get_points():
			point1 = path.get_point_position(point1)
			# Loop through the remaining nodes
			for point2 in nodes:
				# If the node is closer, make it the closest
				if point1.distance_to(point2) < min_dist:
					min_dist = point1.distance_to(point2)
					min_point = point2
					point = point1
		# Insert the resulting node into the path and add
		# its connection
		var next_point = path.get_available_point_id()
		path.add_point(next_point, min_point)
		path.connect_points(path.get_closest_point(point), next_point)
		# Remove the node from the array so it isn't visited again
		nodes.erase(min_point)
	return path

func make_map(path:AStar):
	if not path:
		return
	# Create a TileMap from the generated rooms and path
	clear()

	var full_rect = Rect2()
	for room in $Points.get_children():
		var r = Rect2(room.position-room.size,
					room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)

	# Carve rooms
	var corridors = []  # One corridor per connection
	for room in $Points.get_children():
		set_cell(room.position.x,room.position.y,0)
		# Carve connecting corridor
		var p = path.get_closest_point(Vector3(room.position.x, room.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = world_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = world_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				var path_size = river_size + int(pow(-1,randi()%1)) * randi()%variation #pick a random size + or minus variation
				carve_path(start, end, path_size)
		corridors.append(p)
	update_bitmask_region()
	$Points.queue_free()

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
	for x in range(pos1.x, pos2.x, x_diff):
#		set_cell(x, x_y.y, 0)
#		set_cell(x, x_y.y + y_diff, 0)  # widen the corridor
		for multipler_offset in range(path_size):
			set_cell(x, x_y.y + (multipler_offset * y_diff), 0)
	for y in range(pos1.y, pos2.y, y_diff):
#		set_cell(y_x.x, y, 0)
#		set_cell(y_x.x + x_diff, y, 0)
		for multipler_offset in range(path_size):
			set_cell(y_x.x + (multipler_offset * x_diff), y, 0)
