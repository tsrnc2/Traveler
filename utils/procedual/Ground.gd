extends TileMap

var DEFAULT_WIDTH := 100
var DEFAULT_HEIGHT := 100

export(int) var OCTAVES = 4
export(int) var PERIOD = 15
export(float) var LACUNARITY = 1.5
export(float) var PERSISTENCE = 0.75
export(int) var SEED = randi()

export(float) var WATER_CUTOFF = -0.6
export(float) var SPRING_CUTOFF = -0.4
export(float) var SUMMER_CUTOFF = 0.3
export(float) var FALL_CUTOFF = 0.4
export(float) var WINTER_CUTOFF = 0.5

const TILES = {
	'spring' : 0,
	'summer' : 1,
	'fall' : 2,
	'winter' : 3,
	'water' : 4,
	'mountain' : 5,
}

var open_simplex_noise

func initialize(_width:int = DEFAULT_WIDTH, _height:int = DEFAULT_HEIGHT) -> void:
	randomize()
	open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = SEED
	
	open_simplex_noise.octaves = OCTAVES
	open_simplex_noise.period = PERIOD
	open_simplex_noise.lacunarity = LACUNARITY
	open_simplex_noise.persistence = PERSISTENCE
	_generate_ground(_width, _height)
	_generate_mountain_border(_width, _height)

func _generate_mountain_border(_width, _height) -> void:
	$Mountain.initialize(_width, _height)

func _generate_ground(_width, _height):
	var tile_index
	for x in _width:
		for y in _height:
			tile_index = _get_tile_index(open_simplex_noise.get_noise_2d(float(x),float(y)))
			if tile_index == TILES.mountain:
				pass
#				Mountain.set_cell(x - (_width / 2), y - (_height / 2), 0)
#				set_cell(x - (_width / 2), y - (_height / 2), TILES.winter)
			elif tile_index == TILES.water:
				$Shoreline.set_cell(x - (_width / 2), y - (_height / 2), 0)
				$Shoreline/Waves.set_cell(x - (_width / 2), y - (_height / 2), TILES.water)
			else:
				set_cell(x - (_width / 2), y - (_height / 2), tile_index)
	update_bitmask_region()

func _get_tile_index(noise_sample):
	if noise_sample < WATER_CUTOFF:
		return TILES.water
	if noise_sample < SPRING_CUTOFF:
		return TILES.spring
	if noise_sample < SUMMER_CUTOFF:
		return TILES.summer
	if noise_sample < FALL_CUTOFF:
		return TILES.fall
	if noise_sample < WINTER_CUTOFF:
		return TILES.winter
	return TILES.mountain
