#warning-ignore-all:unused_class_variable
extends Node2D
const WeatherTypes = preload("res://core/world/weather/WeatherTypes.gd")

export(bool) var is_fog = true
export(bool) var is_sun = true
export(int) var weather :int = WeatherTypes.CLEAR
export(int) var temperature := 75
export(int) var HEIGHT := 150
export(int) var WIDTH := 150

export(int) var TRAIN_HOUR : = 6

onready var water := $GroundYsort/Water

func initialize(player_node) -> void:
	print("loading map")
	$TrainRoute.initialize(TRAIN_HOUR)
	water.initialize(get_tree().get_nodes_in_group("weather")[0])
	$GroundYsort.initialize(player_node)
	
func get_ysort_node() -> Node:
	return self
	
func toggle_map(is_enabled:bool) -> void:
	$Ripples.visible = not is_enabled
	$Dispatch.visible = not is_enabled
	
func get_shop_location() -> Vector2:
	return $ShopParking.global_position

func get_walkable_cells() -> Array:
	return $GroundYsort.get_walkable_cells()
	
func get_map_limits() -> Vector2:
	return $GroundYsort/Ground.get_used_rect()
	
func map_to_world(input_vec:Vector2) -> Vector2:
	return $GroundYsort/Ground.map_to_world(input_vec)

func world_to_map(input_vec:Vector2) -> Vector2:
	return $GroundYsort/Ground.world_to_map(input_vec)

func get_residents()-> Node:
	return $Residents
