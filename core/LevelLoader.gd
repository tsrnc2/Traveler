extends Node

signal loaded(level)

export(String, FILE, "*.tscn") var LEVEL_START
#
#var fog_path = "res://core/world/Fog.tscn"

var map : Node
onready var player := $Player
onready var FogOfWar := $FogOfWar
onready var GameClock := $"../GameClock"
var Weather :Node
onready var WorldTimeOfDay := $"../Overlays/WorldTimeOfDay"

var error := OK setget on_error

func on_error(new_error)->void:
	if new_error != OK:
		print("Error in LevelLoader ", new_error)
	error = new_error

func initialize() ->void:
	Weather = get_tree().get_nodes_in_group("weather")[0]
	self.error = connect("loaded",$MapAstar,'initialize')
	remove_child(player)
	remove_child(FogOfWar)
	change_level(LEVEL_START)

func change_level(scene_path) ->void:
	print('loading level')
	if map:
		map.remove_child(player)
		remove_child(map)
		map.queue_free()
	map = load(scene_path).instance()
	add_child(map)
	map.initialize(player)
	map.get_ysort_node().add_child(player)
	var spawn :Node = map.get_node("PlayerSpawningPoint")
	player.initialize(spawn.global_position, GameClock)
	#load lootboxes
	for lootbox in get_tree().get_nodes_in_group("lootbox"):
		lootbox.initialize(player)
	#add Fog of War
	map.add_child(FogOfWar)
	FogOfWar.initialize(player, Vector2(map.HEIGHT, map.WIDTH))
	#initialize weather
	Weather.initialize(map.weather, map.temperature)
	WorldTimeOfDay.initialize(GameClock, map.is_sun)
	#Load cops
	for police in get_tree().get_nodes_in_group("police"):
		police.initialize(player)
	for dispatch in get_tree().get_nodes_in_group("dispatch"):
		dispatch.initialize(player)
	for residents in get_tree().get_nodes_in_group("residents"):
		residents.initialize(map.get_shop_location())
	for npc_with_inventory in get_tree().get_nodes_in_group("npc_inventory"):
		self.error = npc_with_inventory.connect('open_npc_inventory',$"../Interface",'open_npc_inventory')
	emit_signal("loaded", map)

func get_doors() ->Array:
	var doors = []
	for door in get_tree().get_nodes_in_group("doors"):
		if not map.is_a_parent_of(door):
			continue
		doors.append(door)
	return doors
