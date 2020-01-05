extends Camera2D

func initialize(player:Node) -> void:
	player.connect("open_map",self,"toggle_map")
	
func toggle_map(is_enabled:bool) -> void:
	clear_current()
	current = is_enabled
