extends TileMap

var DEFAULT_WIDTH := 100
var DEFAULT_HEIGHT := 100

func initialize(_width:int = DEFAULT_WIDTH, _height:int = DEFAULT_HEIGHT) -> void:
	make_border(_width, _height)
	update_bitmask_region()
	
func make_border(_width:int, _height:int):
# warning-ignore-all:integer_division
	for x in range(-_width/2+1, _width/2-1, 1):
		set_cell( x, -(_height/2)+1, 0)
		set_cell( x, (_height/2)-1, 0)
	for y in range(-_height/2+1, _height/2-1, 1):
		set_cell( -(_width/2)+1, y, 0)
		set_cell( (_width/2)-1, y, 0)
	
