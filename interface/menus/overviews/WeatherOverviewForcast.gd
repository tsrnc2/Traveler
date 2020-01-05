extends HBoxContainer

var WeatherTypes = load("res://core/world/weather/WeatherTypes.gd")

var forcast : PoolIntArray

var dayz : Array

func initialize(weather_node:Node)->void:
	dayz = [$Today,$Day2,$Day3]
	forcast = weather_node.get_forcast()
	for day in range(3):
		set_weather_type(forcast[day],day)
	
func set_weather_type(weather_type:int, day:int)->void:
	dayz[day].initialize(get_weather_string(weather_type), get_weather_animation(weather_type))

func get_weather_string(weather_type:int) -> String:
	match weather_type:
		WeatherTypes.CLEAR:
			return 'Clear'
		WeatherTypes.STORM:
			return 'Stormy'
		WeatherTypes.RAIN:
			return 'Rainy'
		WeatherTypes.WIND:
			return 'Windy'
		WeatherTypes.SNOW:
			return 'Snowy'
	return ''
	
func get_weather_animation(weather_type:int) ->String:
	match weather_type:
		WeatherTypes.CLEAR:
			return 'Sunny'
		WeatherTypes.STORM:
			return 'Stormy'
		WeatherTypes.RAIN:
			return 'Rainy'
		WeatherTypes.WIND:
			return 'Cloudy'
		WeatherTypes.SNOW:
			return 'Snowy'
	return ''
	
