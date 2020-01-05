#warning-ignore-all:unused_class_variable
extends Node2D
const WeatherTypes = preload("res://core/world/weather/WeatherTypes.gd")

var WALKABLE_GROND_TILES = {'Spring':0,'Summer':1,'Fall': 2,'Winter': 3,'SpringRoad':4,'SummerRoad':5,'FallRoad':6,'WinterRoad':7}

export(bool) var is_fog = true
export(bool) var is_sun = true
export(int) var weather :int = WeatherTypes.CLEAR
export(int) var temperature := 75
export(int) var HEIGHT := 150
export(int) var WIDTH := 150


func get_ysort_node() -> Node:
	return $YSort

func initialize(_player_node:Node):
	print('map loading...')
	_clear_map()
	_generate_ground()
	_generate_buildings()
	_generate_water()
	_generate_roads()
	_generate_trees()
	_generate_cops()
	_generate_animals()
	_place_player()
	print('map loaded')

func _clear_map():
	$Ground.clear()
	$Ground/Mountain.clear()
	$Ground/Trees.clear()
	$Ground/Shoreline.clear()
	$Ground/Roads.clear()

func _place_player() -> void:
	while $Ground/Shoreline.get_cellv($Ground/Shoreline.world_to_map($PlayerSpawningPoint.global_position)) == 0:
		$PlayerSpawningPoint.global_position = get_new_pos()
		
func get_new_pos() -> Vector2:
# warning-ignore:unassigned_variable
	var pos : Vector2
	pos.x = randi() % HEIGHT
	pos.y = randi() % WIDTH
	return pos

func _generate_trees() -> void:
	$Ground/Trees.initialize(WIDTH, HEIGHT)

func _generate_ground() -> void:
	$Ground.initialize(WIDTH, HEIGHT)

func _generate_water() -> void:
	$Ground/Shoreline.initialize()
	
func _generate_buildings() -> void:
	$YSort/Buildings.initialize(WIDTH, HEIGHT)

func _generate_roads() -> void:
	$Ground/Roads.initialize(WIDTH, HEIGHT)

func _generate_cops() -> void:
	$Ground/Dispatch.initialize($Ground/Roads)
	pass

func toggle_map(is_enabled:bool) -> void:
	$Ground/Dispatch.visible = not is_enabled
	
func get_shop_location() -> Vector2:
	return $YSort/Buildings/ShopingCenter.global_position

func get_walkable_cells() -> Array:
	var walkable_cells : Array = []
	for cell_id in WALKABLE_GROND_TILES.values():
		walkable_cells += $Ground.get_used_cells_by_id(cell_id)
	walkable_cells.sort()
	for remove_cell in $Ground/Trees.get_used_cells():
		walkable_cells.remove(walkable_cells.bsearch($Ground.world_to_map( $Ground/Trees.map_to_world(remove_cell) ) ) )
	for remove_cell in $Ground/Shoreline.get_used_cells():
		walkable_cells.remove(walkable_cells.bsearch($Ground.world_to_map($Ground/Shoreline.map_to_world(remove_cell) ) ) )
	for used_cell in $Ground/Mountain.get_used_cells_by_id(0):
		walkable_cells.remove( walkable_cells.bsearch( $Ground.world_to_map( $Ground/Mountain.map_to_world( used_cell) ) ))
	return walkable_cells
	

func _generate_animals() -> void:
	pass

func get_map_limits() -> Vector2:
	return $Ground.get_used_rect()
	
func map_to_world(input_vec:Vector2) -> Vector2:
	return $Ground.map_to_world(input_vec)

func world_to_map(input_vec:Vector2) -> Vector2:
	return $Ground.world_to_map(input_vec)
