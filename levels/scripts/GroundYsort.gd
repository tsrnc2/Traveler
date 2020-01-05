extends YSort

var WALKABLE_GROND_TILES = {'Spring':0,'Summer':1,'Fall': 2,'Winter': 3,'SpringRoad':4,'SummerRoad':5,'FallRoad':6,'WinterRoad':7}

onready var ground = $Ground
onready var trees = $Trees
onready var water = $Water
onready var mountain = $Mountain

func initialize(player_node)->void:
	$ObjectYsort.initialize(player_node)

func get_walkable_cells() -> Array:
	var walkable_cells : Array = []
	for cell_id in WALKABLE_GROND_TILES.values():
		walkable_cells += ground.get_used_cells_by_id(cell_id)
	walkable_cells.sort()
	for remove_cell in trees.get_used_cells():
		walkable_cells.remove(walkable_cells.bsearch(ground.world_to_map(trees.map_to_world(remove_cell) ) ) )
	for remove_cell in water.get_used_cells():
		walkable_cells.remove(walkable_cells.bsearch(ground.world_to_map(water.map_to_world(remove_cell) ) ) )
	for used_cell in mountain.get_used_cells_by_id(0):
		walkable_cells.remove( walkable_cells.bsearch( ground.world_to_map( mountain.map_to_world( used_cell) ) ))

#		for y in range(-2,2):
#			for x in range(-2,2):
#				print(used_cell + Vector2(x,y))
#				walkable_cells.remove( walkable_cells.bsearch( ground.world_to_map( mountain.map_to_world( used_cell + Vector2(x,y)) ) ) )

	print("Ground Ysort Loaded: walkable cell array size ", walkable_cells.size())
	return walkable_cells
