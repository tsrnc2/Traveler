extends Control

export(PackedScene) var Overview := preload("res://interface/menus/overviews/WeatherOverview.tscn")

var Overview_Pointer: Node

var WeatherTypes = load("res://core/world/weather/WeatherTypes.gd")

onready var temp_readout = $"HBoxContainer/VBoxContainer/TempReadout"
onready var weather_readout = $"HBoxContainer/VBoxContainer/WeatherReadout"
onready var thermometer = $"HBoxContainer/Thermometer"

var error :int= OK setget on_error

var Weather_Node :Node

func on_error(new_error) -> void:
	error = new_error
	print("Error in WeatherHUD :", error)

func initialize(weather_node : Node) -> void:
	Weather_Node = weather_node
	error = weather_node.connect("temperature_changed", self, "update_temperature")
	error = weather_node.connect("weather_changed", self, "update_weather")
	update_temperature(weather_node.world_temperature)
	update_weather(weather_node.get_weather())

func update_temperature(new_temperature: int) -> void:
	thermometer.value = new_temperature
	temp_readout.text = String(new_temperature) + "°"

func update_weather(new_weather: int) -> void:
	if new_weather == WeatherTypes.CLEAR:
		weather_readout.text = "Clear"
	elif new_weather == WeatherTypes.STORM:
		weather_readout.text = "Stormy"
	elif new_weather == WeatherTypes.RAIN:
		weather_readout.text = "Rainy"
	elif new_weather == WeatherTypes.SNOW:
		weather_readout.text = "Snowy"
	elif new_weather == WeatherTypes.WIND:
		weather_readout.text = "Windy"

func _on_WeatherHUD_mouse_entered():
	if Overview_Pointer:
		return
	var new_overview := Overview.instance()
	add_child(new_overview)
	new_overview.initialize(Weather_Node)
	new_overview.show()
	Overview_Pointer = new_overview
	yield(Overview_Pointer,"closed")
	if not Overview_Pointer:
		Overview_Pointer = null
		return
	Overview_Pointer.queue_free()
	Overview_Pointer = null
