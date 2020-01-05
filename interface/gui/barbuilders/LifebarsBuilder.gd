extends Node

const Quotebar = preload("res://interface/gui/lifebar/HookableQuotePanel.tscn")

export(String) var GROUP_NAME := 'npc'

func initialize(group_name:String = GROUP_NAME):
	for actor in get_tree().get_nodes_in_group(group_name):
		create_quotebar(actor)
		actor.connect('spawned_cop', self, '_on_spawned_cop')

func _on_spawned_cop(cop_node):
	create_quotebar(cop_node)

func create_quotebar(actor):
	if not actor.has_node('InterfaceAnchor'):
		return
	var quotebar = Quotebar.instance()
	actor.add_child(quotebar)
	quotebar.initialize(actor)
