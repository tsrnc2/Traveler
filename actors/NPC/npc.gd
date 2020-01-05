extends KinematicBody2D

# warning-ignore:unused_signal
signal died
signal speaking
var error :int = OK setget on_error

# warning-ignore:unused_class_variable
onready var InfoHUB :Node = get_tree().get_nodes_in_group("InfoHUD")[0]

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("Error in NPC :",self.name, " Error :", error)

func speak(new_text:String) -> void:
	emit_signal("speaking", new_text)
