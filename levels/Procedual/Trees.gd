extends TileMap

var DEFAULT_WIDTH := 100
var DEFAULT_HEIGHT := 100

export(int) var OCTAVES = 4
export(int) var PERIOD = 15
export(float) var LACUNARITY = 1.5
export(float) var PERSISTENCE = 0.75
export(int) var SEED = randi()

export(float) var TREE_SNOW_CUTOFF = -0.7
export(float) var TREE_PARTLY_SNOW_CUTOFF = -0.6
export(float) var TREE_CUTOFF = -0.5
export(float) var DEADTREE_CUTOFF = -0.4

onready var Mountain = $"../Mountain"
onready var Water = $"../Shoreline"
onready var Roads = $"../Roads"

const TILES = {
	'partly_snowy_pine':  10,
	'pine':  11,
	'snowy_pine':  9,
	'tree' : 1,
	'deadtree' : 3,
	'green_tree' : 4,
	'fall': 5,
	'bushes': 6,
	'green_pine': 7,
	'autumn': 9,
	'clear' : -1,
}

var open_simplex_noise

func initialize(_width:int = DEFAULT_WIDTH, _height:int = DEFAULT_HEIGHT) -> void:
	print("loading trees")
	randomize()
	open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = SEED
	
	open_simplex_noise.octaves = OCTAVES
	open_simplex_noise.period = PERIOD
	open_simplex_noise.lacunarity = LACUNARITY
	open_simplex_noise.persistence = PERSISTENCE
	_generate_trees(_width, _height)
	
func _generate_trees(_width:int, _height:int) -> void:
	var tile_index
	for x in _width:
		for y in _height:
			#if no moutain or river or roads in the way
			var curr_cell := Vector2(x-_width/2, y - _height/2)
			if (Water.get_cellv(curr_cell) != 0 and Mountain.get_cellv(curr_cell) != 0 and Roads.get_cellv(curr_cell) == -1) and Roads.get_cellv(curr_cell - Vector2(0,-1)) == -1:
				tile_index = _get_tile_index(open_simplex_noise.get_noise_2d(float(x),float(y)))
				set_cellv(curr_cell, tile_index)
	update_bitmask_region()
	
func is_cell_clear(curr_cell:Vector2) -> bool:
	return Water.get_cell(curr_cell) != 0 and Mountain.get_cell(curr_cell) != 0 and Roads.get_cell(curr_cell) == -1
	
func _get_tile_index(noise_sample) ->int:
	if noise_sample < TREE_SNOW_CUTOFF:
		return TILES.snowy_pine
	elif noise_sample < TREE_SNOW_CUTOFF:
		return TILES.partly_snowy_pine
	elif noise_sample < TREE_SNOW_CUTOFF:
		return TILES.pine	
	elif noise_sample < DEADTREE_CUTOFF:
		return TILES.deadtree
	return TILES.clear
