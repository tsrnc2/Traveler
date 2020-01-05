extends TileMap

enum NIGHTCYCLE {
	MORNING = 0,
	DAY = 1,
	NIGHT =2
}

var visablity := 0
var visablity_bonus := 0 
export var DEFAULT_SIZE := Vector2(75,75)
export(bool) var IS_UNCOVERED_FOG := false
onready var FogOfWar := $BackgroundFog
onready var sun_overlay :Node= get_tree().get_nodes_in_group("SunOverlay")[0]

var CameraNode : Camera2D

const DAY_BONUS_VISION := 2
const MORNIG_BONUS_VISION := 1

var part_of_day: int = NIGHTCYCLE.NIGHT

export(int) var PADDING := 20

var error :int= OK setget on_error

func on_error(new_error:int) ->void:
	error = new_error
	if error != OK:
		print("Error in FogofWar :", error)

func initialize(_player_node, level_size:Vector2 = DEFAULT_SIZE) -> void:
	self.error = sun_overlay.connect("parts_of_day",self,"new_part_of_day")
	sun_overlay.state = part_of_day
	self.error = _player_node.connect('position_changed', self, '_on_player_position_changed')
	self.error = _player_node.connect('visablity_changed', self, '_on_player_visablity_changed')
	visablity = _player_node.visablity
	CameraNode = _player_node.get_node("Camera")
	get_parent().move_child(self, 0)
	cover_grid(level_size)
	_on_player_position_changed(_player_node.global_position)
	
func new_part_of_day(part:int)->void:
	match part:
		NIGHTCYCLE.DAY:
			visablity_bonus = DAY_BONUS_VISION
		NIGHTCYCLE.MORNING:
			visablity_bonus = MORNIG_BONUS_VISION
		NIGHTCYCLE.NIGHT:
			visablity_bonus = 0

func _on_player_visablity_changed(new_visablity:int, player_global_position:Vector2) ->void:
	if IS_UNCOVERED_FOG:
		recover_fog(FogOfWar.world_to_map(player_global_position))
	visablity = new_visablity
	_on_player_position_changed(player_global_position)

func cover_grid(level_size:Vector2,tile := 0) -> void:
	for x in range(int(-level_size.x/2 - PADDING), int(level_size.x/2 + PADDING)):
		for y in range(int(-level_size.y/2 - PADDING),int(level_size.y/2 + PADDING)):
			set_cellv(Vector2(x,y), tile)
			if IS_UNCOVERED_FOG:
				FogOfWar.set_cellv(Vector2(x,y),tile)

func _on_player_position_changed(player_world_pos: Vector2) -> void:
	var player_map_pos = world_to_map(player_world_pos)
	#set vision clear
	set_cellv(player_map_pos ,-1)
	for x_offset in range(visablity + visablity_bonus):
		for y_offset in range(visablity + visablity_bonus):
			set_cell_block(player_map_pos,x_offset,y_offset,-1)
			if IS_UNCOVERED_FOG:
				set_cell_block(player_map_pos,x_offset,y_offset,-1,FogOfWar)
	#enable fog when not in range
	if IS_UNCOVERED_FOG:
		recover_fog(player_map_pos)
		
func recover_fog(player_map_pos:Vector2)->void:
	for x_offset in range(visablity + visablity_bonus + 1):
		set_cell_block(player_map_pos, x_offset, visablity + 1, 0, FogOfWar)
		set_cell_block(player_map_pos, -x_offset, -visablity - 1, 0, FogOfWar)
	for y_offset in range(visablity + visablity_bonus + 1):
		set_cell_block(player_map_pos, visablity + 1,y_offset, 0, FogOfWar)
		set_cell_block(player_map_pos, -visablity - 1, -y_offset ,0, FogOfWar)

func set_cell_block(player_map_pos:Vector2, _x_offset:int, _y_offset:int, tile:int, tilemap = self) -> void:
	tilemap.set_cellv(Vector2(player_map_pos.x - _x_offset, player_map_pos.y - _y_offset)  ,tile)
	tilemap.set_cellv(Vector2(player_map_pos.x + _x_offset, player_map_pos.y + _y_offset)  ,tile)
	tilemap.set_cellv(Vector2(player_map_pos.x - _x_offset, player_map_pos.y + _y_offset)  ,tile)
	tilemap.set_cellv(Vector2(player_map_pos.x + _x_offset, player_map_pos.y - _y_offset)  ,tile)

func _on_LevelLoader_loaded(level):
	visible = level.is_fog
	FogOfWar.visible = level.is_fog

func _process(_delta):
	var fog_offset = CameraNode.get_camera_position() / get_viewport().size;
	FogOfWar.material.set_shader_param("offset", Vector2(fog_offset.x,-fog_offset.y))
