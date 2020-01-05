extends Control

func initialize(forcast:String, weather:String)->void:
	$Label/WeatherName.text = forcast
	$Label/WeatherIcon.play(weather)
