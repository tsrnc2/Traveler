extends Node

const Quotebar = preload("res://interface/gui/barbuilders/HookableQuotePanel.tscn")

export(String) var TALKABLE_GROUP_NAME := 'npc'
export(String) var SPAWNABLE_GROUP_NAME := 'npc'

var error := OK setget on_error

func on_error(new_error)->void:
	error = new_error
	if error != OK:
		print("Error in QuoteBarBuilder :", error)

func initialize(group_name:String = TALKABLE_GROUP_NAME, spawn_group_name:String = SPAWNABLE_GROUP_NAME):
	for actor in get_tree().get_nodes_in_group(group_name):
		create_quotebar(actor)
	for actor in get_tree().get_nodes_in_group(spawn_group_name):
		self.error = actor.connect('spawned', self, '_on_spawned')

func _on_spawned(actor:Node) -> void:
	create_quotebar(actor)

func create_quotebar(actor:Node)->void:
	var quotebar = Quotebar.instance()
	actor.add_child(quotebar)
	quotebar.initialize(actor)
