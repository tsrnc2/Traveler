extends Node

var weather_node : Node
var inventory_node : Node

var WeatherTypes = load("res://core/world/weather/WeatherTypes.gd")

var weather : int
var temperature : int

export(float) var WETNESS_EFFECT = 50.0 #1-100

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Player EnvironmentalEffects :", error)

func initialize(_inventory_node : Node)->void:
	inventory_node = _inventory_node
	weather_node = get_tree().get_nodes_in_group("weather")[0]
	self.error = weather_node.connect('weather_changed',self,'weather_changed')
	self.error = weather_node.connect('temperature_changed',self,'temperature_changed')
	self.error = get_tree().get_nodes_in_group("clock")[0].connect('quarter_hour_update',self,'quarter_hour_update')
	
	weather = weather_node.get_weather()
	temperature = weather_node.get_world_temperature()

func weather_changed(new_weather :int)->void:
	weather = new_weather
	
func temperature_changed(new_temperature:int)->void:
	temperature = new_temperature
	
func quarter_hour_update()->void:
	if not is_raining():
		return
	for clothing in inventory_node.get_equipment_list().values():
		print(clothing.display_name)
#		clothing.get_item_wet(WETNESS_EFFECT)

func is_raining()->bool:
	match weather:
		WeatherTypes.STORM:
			return true
		WeatherTypes.RAIN:
			return true
		WeatherTypes.SNOW:
			return true
	return false
