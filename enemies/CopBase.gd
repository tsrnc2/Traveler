# warning-ignore-all:unused_class_variable
extends "res://actors/NPC/npc.gd"

var state : int
var active : bool

export(float) var ARRIVE_DISTANCE := 6.0
export(float) var DEFAULT_SLOW_RADIUS := 200.0
export(float) var DEFAULT_MAX_SPEED := 150.0
export(float) var MASS := 8.0

export(int) var WANTED_LEVEL_INCREASE := 10

export(String) var WARNING_MESSAGE := "This is a warning I dont want to see you here again\n"
export(String) var PULLOVER_MESSAGE := "The Police Are tying to pull you over\n Press < TAB > to surrender"
export(Color) var MESSAGECOLOR := Color('800e0e')

const Actor := preload("res://actors/Actor.gd")
var target :Node= null # Actor

var start_position := Vector2()
var velocity := Vector2()

func _ready():
	start_position = global_position

func initialize(target_actor: Node) -> void:
	if not target_actor is Actor:
		return
	target = target_actor
	self.error = target.connect('died', self, '_on_target_died')
	set_active(true)

func _on_target_died() -> void:
	target = null

func set_active(value) -> void:
	active = value
	set_physics_process(value)
