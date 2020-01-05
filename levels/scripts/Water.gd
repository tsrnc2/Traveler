tool
extends TileMap

const WeatherTypes = preload("res://core/world/weather/WeatherTypes.gd")

const Splash = preload("res://core/world/weather/Splash.tscn")

export var PERCENT_OF_SPLASH := 0.1

var NUMBER_OF_SPLASH := int(get_used_cells().size() * PERCENT_OF_SPLASH)
var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Water :", error)

var cell_list :Array
var list_of_splash : Array
var timer : Timer

var is_raining : bool
func initialize(weather_node)->void:
	print("loading water animations")
	randomize()
	self.error = weather_node.connect("weather_changed",self,"weather_changed")
	weather_changed(weather_node.weather_state)
	cell_list = get_used_cells()
	create_splash(NUMBER_OF_SPLASH)
	timer = Timer.new()
	add_child(timer)
	self.error = timer.connect("timeout",self,"animate_cells")
	animate_cells()

func create_splash(_num:int)->void:
	for _i in range(_num):
		add_splash()

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

func animate_cells()->void:
	for cell in cell_list:
		var new_cell_id = get_cellv(cell) + 1
		if new_cell_id > 20:
			new_cell_id = 0
		set_cellv(cell,new_cell_id)
	if is_raining:
		update_splash_list()
	timer.start(0.1)

func update_splash_list()->void:
	var i = -1
	for splash in list_of_splash:
		i += 1
		if splash.frame != 7:
			continue
		splash.free()
		list_of_splash.remove(i)
	if list_of_splash.size() < NUMBER_OF_SPLASH:
		create_splash(NUMBER_OF_SPLASH - list_of_splash.size())

func add_splash()->void:
	if not cell_list:
		return
	var splash_location := map_to_world(cell_list[randi() % cell_list.size()-1])
	while not is_in_splash_list(splash_location):
		splash_location = map_to_world(cell_list[randi() % cell_list.size()-1])
	var new_splash = Splash.instance()
	add_child(new_splash)
	new_splash.global_position = splash_location
	new_splash.play('splash')
	list_of_splash.append(new_splash)

func is_in_splash_list(check_location:Vector2)->bool:
	for spash in list_of_splash:
		if spash.global_position == check_location:
			return false
	return true
