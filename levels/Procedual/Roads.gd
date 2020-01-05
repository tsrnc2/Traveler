extends TileMap
signal roads_complete
signal astar_complete

export(Vector2) var tile_size := Vector2(80,40)  # size of a tile in the TileMap
export(int) var NUM_OF_CELLS := 25 # number of points to connect in network
export(int) var DEFAULT_HEIGHT := 150
export(int) var DEFAULT_WIDTH := 150
export(float) var CULL_PERCENT := 0.0

#Road bitmasking
const NORTH_MASK = 0x1
const EAST_MASK = 0x2
const SOUTH_MASK = 0x4
const WEST_MASK = 0x8
const WATER_MASK = 0x16

const cell_walls = {Vector2(0, -1): NORTH_MASK, Vector2(1, 0): EAST_MASK,
				  Vector2(0, 1): SOUTH_MASK, Vector2(-1, 0): WEST_MASK}

var cell = preload("res://core/world/road/Points.tscn")

var path : AStar # AStar pathfinding object

var points_positions := []

onready var Water := $"../Water"
onready var Mountain := $"../Mountain"
onready var Trees := $"../Trees"
onready var Ground := get_parent()

func initialize(_width:int = DEFAULT_WIDTH, _height:int = DEFAULT_HEIGHT, _Water_Node : TileMap = Water, _Mountain_Node : TileMap = Mountain, _Tree_Node : TileMap = Trees) -> void:
	randomize()
	Water = _Water_Node
	Mountain = _Mountain_Node
	Trees = _Tree_Node
	
	print('loading roads')
	path = AStar.new() # AStar pathfinding object
	make_points(_width,_height)
	cull_points()
	if path and points_positions:
		find_mst()
		make_map(path)
	apply_bitmask()
	emit_signal("roads_complete")
	
func apply_bitmask():
		for cell_pos in get_used_cells():
			var placable_cell_array : Array = find_valid_tiles(cell_pos)
			var cell_index :int = placable_cell_array[ randi() % placable_cell_array.size()]
			set_cellv(cell_pos,cell_index)

func make_points(_width:int,_height:int) -> void:
	var num_of_cells = 0
	var used_cells = []
	used_cells = get_used_cells()
	for pos in used_cells:
		var c = cell.instance()
		c.make_points(map_to_world(pos))
		$Points.add_child(c)
		num_of_cells += 1
	if num_of_cells < NUM_OF_CELLS:
		for i in range(NUM_OF_CELLS - num_of_cells):
			var c = cell.instance()
			var pos := Vector2( randi() % _width - (_width / 2) , randi() % _height - (_height / 2) )
			#only pick pints on ground
			while ( Water.get_cellv(pos) != -1 or Mountain.get_cellv(pos) != -1 ):
				pos = Vector2( randi() % _width - (_width / 2) , randi() % _height - (_height / 2) )
			c.make_points( map_to_world(pos))
			$Points.add_child(c)

func cull_points() -> void:
	for point in $Points.get_children():
		if randf() < CULL_PERCENT:
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

func make_map(path:AStar) -> void:
	 # Carve rivers
	var connections = []  # One corridor per connection
	for cell in $Points.get_children():
		set_cellv(world_to_map(Vector2(cell.position.x, cell.position.y)), 0)
		# Carve connecting corridor
		var p = path.get_closest_point(Vector3(cell.position.x, cell.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in connections:
				var start = world_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = world_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				carve_path(start, end)
		connections.append(p)
	update_bitmask_region()
	$Points.queue_free()

func carve_path(pos1:Vector2, pos2:Vector2) -> void:
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
		set_cell( x, x_y.y, 0)
#		Trees.set_cell(x, x_y.y, -1)
#		Mountain.set_cell(x, x_y.y, -1)
		Water.set_cell(x, x_y.y, -1)
	for y in range(pos1.y, pos2.y, y_diff):
		set_cell( y_x.x, y, 0)
#		Trees.set_cell(y_x.x, y, -1)
#		Mountain.set_cell(y_x.x, y, -1)
		Water.set_cell(y_x.x, y, -1)

func find_valid_tiles(cell:Vector2) -> Array:
	var valid_tiles = []
	# returns all valid tiles for a given cell
	for i in range(16):
		# check target space's neighbors (if they exist)
		for n in cell_walls.keys():
			var neighbor_id :int = get_cellv(cell + n)
			if neighbor_id >= 0:
				if (neighbor_id & cell_walls[-n])/cell_walls[-n] == (i & cell_walls[n])/cell_walls[n]:
					if not i in valid_tiles:
						valid_tiles.append(i)
	if valid_tiles:
		return valid_tiles
	else:
		return [0]
