extends Node
#Arrays of vector2 cor for tiles of respective types
var residential_list : Array
var work_list : Array
var roads_list : Array

var shop_location : Vector2

export(PackedScene) var Resident = preload("res://actors/resident/ResidentVehicle.tscn")

export(int) var ROAD_SIZE_MULTIPLYER = 2
export(int) var MAXNUMOFRESEDENTS :int= 50
export(int) var MAXTILESEARCH := 5 #num of tiles to search on each axis
onready var RESIDENTIAL = get_tree().get_nodes_in_group("ResidentialBuildings")[0]
onready var WORK = get_tree().get_nodes_in_group("WorkBuildings")[0]
onready var ROADS = get_tree().get_nodes_in_group("Roads")[0]
onready var DISPATCH = get_tree().get_nodes_in_group("dispatch")[0]

func initialize(_shop_location:Vector2 = Vector2(), _residential := RESIDENTIAL, _work := WORK, _roads := ROADS, road_size_multiplyer := ROAD_SIZE_MULTIPLYER) -> void:
	print("loading residents")
	RESIDENTIAL = _residential
	WORK = _work
	ROADS = _roads
	ROAD_SIZE_MULTIPLYER = road_size_multiplyer
	shop_location = _shop_location
	residential_list = get_residential_list()
	work_list = get_work_list()
	for child in get_children(): # residents
		if child.is_in_group('resident_walker'):
			child.initialize(get_parent())
	get_roads_list(roads_list)
	spawn_residents( int(min(residential_list.size(),MAXNUMOFRESEDENTS)) )

func get_work_list() -> Array:
	return WORK.get_used_cells()

func get_residential_list() -> Array:
	return RESIDENTIAL.get_used_cells()

func get_roads_list(roads: Array = roads_list) -> void:
	for cell in ROADS.get_used_cells():
		roads.append( cell * ROAD_SIZE_MULTIPLYER )
	
func spawn_residents(num_of_resedents: int = 1) -> void:
	for i in range(num_of_resedents):
		create_resident(i)

func create_resident(element_iteration) -> void:
	if element_iteration > residential_list.size() or element_iteration > work_list.size():
		return
	var res :Vector2 = residential_list[element_iteration]
	var nearest_road : Vector2 = find_nearest_road(res) / ROAD_SIZE_MULTIPLYER
	var work:Vector2 = get_work_location()
	var nearest_work_road : Vector2 = find_nearest_road(work) / ROAD_SIZE_MULTIPLYER
	# if valid locations make new resident
	if nearest_road != Vector2(0,0) and nearest_work_road != Vector2(0,0):
		var new_resident = Resident.instance()
		new_resident.initialize(nearest_road, nearest_work_road, ROADS, DISPATCH)
		add_child(new_resident)
	
func find_nearest_road(res : Vector2) -> Vector2:
	if res in roads_list:
		return res
	for x in range(MAXTILESEARCH):
		for y in range(MAXTILESEARCH):
			if res + Vector2(x, y) in roads_list:
				return res + Vector2(x, y)
			if res + Vector2(-x,-y) in roads_list:
				return res + Vector2(-x, -y)
			if res + Vector2(x, -y) in roads_list:
				return res + Vector2(x, -y)
			if res + Vector2(-x,y) in roads_list:
				return res + Vector2(-x, y)
	return Vector2(0,0)
	
func get_work_location() ->Vector2:
	return work_list[randi() % work_list.size()]
