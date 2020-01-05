extends Panel

export(PackedScene) var PlayerOverview := preload("res://interface/menus/overviews/PlayerOverview.tscn")

var Overview_Pointer: Node

func _on_HungerPanel_mouse_entered():
	if Overview_Pointer:
		return
	var new_overview := PlayerOverview.instance()
	add_child(new_overview)
	new_overview.initialize()
	Overview_Pointer = new_overview

func _on_HungerPanel_mouse_exited():
	if not Overview_Pointer:
		return
	Overview_Pointer.close()
	yield(Overview_Pointer,"closed")
	Overview_Pointer.queue_free()
	Overview_Pointer = null
