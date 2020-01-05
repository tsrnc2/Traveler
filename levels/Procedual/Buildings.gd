extends Node

signal buildings_complete

onready var Mill := $Mill
onready var Water : TileMap = $"../../Ground/Water"
onready var Ground: TileMap = $"../../Ground"

export(int) var DEFAULT_HEIGHT = 100
export(int) var DEFAULT_WIDTH = 100
export(Vector2) var MILL_GROUND_PATH_SIZE = Vector2(4,8)
export(Vector2) var MILL_GROUND_OFFSET = Vector2(-2,-2)
export(Vector2) var MILL_WATER_OFFSET = Vector2(2,-1)
export(Vector2) var MILL_POND_SIZE = Vector2(4,5)

func initialize(_height := DEFAULT_HEIGHT, _width := DEFAULT_WIDTH, _Ground_Node: TileMap = Ground, _Water_Node:TileMap = Water ) -> void:
	Water = _Water_Node
	Ground = _Ground_Node
#	place_mill(_height,_width)
	
#func place_mill(_height, _width) -> void:
#	Mill.visible = false
#	#pick random location and move mill
#	Mill.position = Vector2(int(((randi() % _height) + 1 )/2), int(((randi() % _width) + 1 )/2))
#	#set water cells
#	var pos :Vector2 = Water.world_to_map(Mill.position)
#	for x in range(MILL_POND_SIZE.x):
#		for y in range(MILL_POND_SIZE.y):
#			Water.set_cellv(pos + MILL_WATER_OFFSET + Vector2(x,y), 0)
#	Water.update_bitmask_region(pos+MILL_WATER_OFFSET, pos + MILL_WATER_OFFSET + MILL_POND_SIZE)
#	Mill.visible = true
#
#func clean_up_mill():
#	var pos:Vector2 = Water.world_to_map(Mill.position)
#	for x in range(MILL_GROUND_PATH_SIZE.x):
#		for y in range(MILL_GROUND_PATH_SIZE.y):
#						Water.set_cellv(pos + MILL_GROUND_OFFSET + Vector2(x,y), -1)
#						Ground.set_cellv(pos + MILL_GROUND_OFFSET + Vector2(x,y), 0)
#	Water.update_bitmask_region(pos+MILL_GROUND_OFFSET, pos + MILL_GROUND_OFFSET + MILL_GROUND_PATH_SIZE)
#	Ground.update_bitmask_region(pos+MILL_GROUND_OFFSET, pos + MILL_GROUND_OFFSET + MILL_GROUND_PATH_SIZE)

func _on_Water_river_complete():
	#make ground path around mill
#	clean_up_mill()
	emit_signal("buildings_complete")
