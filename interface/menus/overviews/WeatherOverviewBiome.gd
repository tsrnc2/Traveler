extends TextureRect

var WeatherTypes = load("res://core/world/weather/WeatherTypes.gd")

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in WeatherOverview Biome :", error)

func initialize(weather_node:Node)->void:
	self.error = weather_node.connect('weather_changed',self,'change_weather')
	change_weather(weather_node.get_weather())
	
func change_weather(weather_type:int)->void:
	match weather_type:
		WeatherTypes.CLEAR:
			$Weather.visible = false
			$Sun.visible = true
		WeatherTypes.STORM:
			$Sun.visible = false
			$Weather.visible = true
			$Weather.play('Rain')
		WeatherTypes.RAIN:
			$Sun.visible = false
			$Weather.visible = true
			$Weather.play('Rain')
		WeatherTypes.WIND:
			$Weather.visible = false
		WeatherTypes.SNOW:
			$Sun.visible = false
			$Weather.visible = true
			$Weather.play('Snow')
	
