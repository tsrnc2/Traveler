extends Panel

export(PackedScene) var HungerOverview := preload("res://interface/menus/overviews/WantedLevelOverview.tscn")

var Overview_Pointer: Node

func _on_WantedLevelPanel_mouse_entered():
	if Overview_Pointer:
		return
	var new_overview := HungerOverview.instance()
	add_child(new_overview)
	new_overview.initialize()
	Overview_Pointer = new_overview

func _on_WantedLevelPanel_mouse_exited():
	if not Overview_Pointer:
		return
	Overview_Pointer.queue_free()
	Overview_Pointer = null
