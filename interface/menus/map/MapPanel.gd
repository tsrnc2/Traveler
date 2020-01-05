extends Control
var error :int = OK setget on_error

func on_error(new_error)->void:
	new_error = error
	if error != OK:
		print("Error in MapPanel:", error)

func initialize(player:Node) -> void:
	self.error = player.connect("open_map",self,"open_map")

func open_map(is_open:bool = true) -> void:
	visible = is_open
