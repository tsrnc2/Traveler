extends CanvasLayer

signal weather_changed
signal temperature_changed

onready var Audio := $StormAudio
onready var Rain := $Rain

enum NIGHTCYCLE {
	MORNING = 0,
	DAY = 1,
	NIGHT = 2
}

enum TEMP_OFFSET {
	MORNING = 12,
	DAY = 0,
	NIGHT = 15
}

var WeatherTypes = load("res://core/world/weather/WeatherTypes.gd")

onready var Lightning := $Lightning
onready var tween := $Tween

var part_of_day :int = NIGHTCYCLE.MORNING
var weather_state : int = WeatherTypes.CLEAR setget set_weather, get_weather
var base_temperature :int = 60 # fahrenheit
var world_temperature :int = apply_time_temp_offsets(base_temperature) setget set_world_temperature

var weather_forcast : PoolIntArray

func initialize(_weather_state :int = weather_state, _temperature :int = base_temperature) -> void:
	randomize()
	weather_forcast = create_weather_forcast()
	set_base_temperature(_temperature)
	Lightning.initialize(false)
	set_weather(weather_forcast[0])

func create_weather_forcast(days := 7)->PoolIntArray:
	var new_forcast : PoolIntArray = []
	for _i in range(days):
		new_forcast.append(randi() % WeatherTypes.SNOW)
	return new_forcast
	
func get_world_temperature()->int:
	return world_temperature
	
func set_world_temperature(new_temperature):
	if new_temperature == world_temperature:
		return
	emit_signal("temperature_changed", world_temperature)
	world_temperature = new_temperature

func set_base_temperature(new_temperature : int) -> void:
	base_temperature = new_temperature
	tween.interpolate_property(self, 'world_temperature', world_temperature, apply_time_temp_offsets(base_temperature), 8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func set_weather(_new_state : int) -> void:
	emit_signal("weather_changed",_new_state)
	change_weather(_new_state)
	weather_state = _new_state

func get_forcast()->PoolIntArray:
	return weather_forcast

func get_weather()->int:
	return weather_state

func change_weather(_new_state : int) -> void:
	if _new_state == weather_state:
		return
	if _new_state == WeatherTypes.CLEAR:
		Lightning.set_storm_state(false)
		Audio.play(false)
		Rain.visible = false
	if _new_state == WeatherTypes.RAIN:
		Lightning.set_storm_state(false)
		Audio.play(true)
		Rain.visible = true
	if _new_state == WeatherTypes.STORM:
		Lightning.set_storm_state(true)
		Audio.play()
		Rain.visible = true

func apply_time_temp_offsets(base_temp) -> int:
	if part_of_day == NIGHTCYCLE.MORNING:
		return base_temp - TEMP_OFFSET.MORNING
	if part_of_day == NIGHTCYCLE.DAY:
		return base_temp - TEMP_OFFSET.DAY
	else:
		return base_temp - TEMP_OFFSET.NIGHT

func _on_WorldTimeOfDay_parts_of_day(_part_of_day:int) -> void:
	part_of_day = _part_of_day
	set_base_temperature(base_temperature)
