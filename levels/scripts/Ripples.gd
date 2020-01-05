extends TileMap

const WeatherTypes = preload("res://core/world/weather/WeatherTypes.gd")

export(float) var SPLASH_PERCENT := 0.02
var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Ripples :", error)

var cell_list :Array
var list_of_splash : Array
var timer : Timer

var is_raining : bool

func initialize(weather_node)->void:
	randomize()
	weather_node.connect("weather_changed",self,"set_is_raining")
	weather_changed(weather_node.weather_state)
	list_of_splash = get_splashes()
	cell_list = get_used_cells()
	timer = Timer.new()
	add_child(timer)
	self.error = timer.connect("timeout",self,"new_weather")
	animate_cells()

func weather_changed(new_weather:int) ->void:
	match new_weather:
		WeatherTypes.CLEAR:
			is_raining = false
		WeatherTypes.STORM:
			is_raining = true
		WeatherTypes.RAIN:
			is_raining = true
		WeatherTypes.WIND:
			is_raining = false
		WeatherTypes.SNOW:
			is_raining = true
	

func get_splashes()-> Array:
	var splash_array := get_children()
	var i = 0
	for child in splash_array:
		if child is AnimatedSprite:
			continue
		splash_array.remove(i)
		i += 1
	return splash_array

func animate_cells()->void:
	for cell in cell_list:
		var new_cell_id = get_cellv(cell) + 1
		if new_cell_id > 20:
			new_cell_id = 0
		set_cellv(cell,new_cell_id)
	animate_splashes()
	timer.start(0.1)

func animate_splashes()->void:
	for splash in list_of_splash:
		if splash.is_playing():
			continue
		if randf() < SPLASH_PERCENT:
			print('splash')
			splash.play('splash')
