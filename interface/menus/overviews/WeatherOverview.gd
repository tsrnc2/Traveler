extends NinePatchRect
export(float) var ANIMATION_TIME := 1.5

signal closed
var tween : Tween

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Weather Overview :", error)

var tween_error :bool=true setget on_tween_error

func on_tween_error(new_error:bool)->void:
	tween_error = new_error
	if tween_error != true:
		print("error in Weather Overview tween :")

var open_rotation:float
var close_rotation:float

var open_position:Vector2
var close_position:Vector2

var is_open := false

var Weather: Node
var WeatherTypes = load("res://core/world/weather/WeatherTypes.gd")

var current_weather : int = WeatherTypes.CLEAR
var forcast : PoolIntArray 
var temperature : int

func initialize(_weather_node)->void:
	Weather = _weather_node
	current_weather = Weather.get_weather()
	forcast = Weather.get_forcast()
	temperature = Weather.get_world_temperature()
	self.error = Weather.connect("weather_changed",self,'weather_changed')
	self.error = Weather.connect("temperature_changed", self, 'temperature_changed')
	$VBox/TitlePanel.title = get_weather_string(current_weather)
	visible = false
	tween = Tween.new()
	add_child(tween)
	open_rotation = 0
	close_rotation = -180
	open_position = rect_position
	close_position = open_position - Vector2(100,800)
	$VBox/WeatherBiome.initialize(_weather_node)
	$VBox/Forcast.initialize(_weather_node)

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

func weather_changed(new_weather:int)->void:
	current_weather = new_weather
	
func temperature_changed(new_temp:int)->void:
	temperature = new_temp

func show()->void:
	if is_open:
		return
	is_open = true
	print("opening player panel")
	rect_rotation = -90
	visible = true
	self.error = tween.interpolate_property(self,'rect_position', close_position, open_position, ANIMATION_TIME,Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.error = tween.interpolate_property(self,'rect_rotation', close_rotation, open_rotation, ANIMATION_TIME,Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.error = tween.start()

func close()->void:
	if tween.is_active:
		print('tween still working')
		yield(tween,"tween_all_completed")
	print("closing player panel")
	self.error = tween.interpolate_property(self,'rect_position', open_position, close_position,ANIMATION_TIME, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	self.error = tween.interpolate_property(self,'rect_rotation', open_rotation, close_rotation, ANIMATION_TIME, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	self.error = tween.start()
	yield(tween, "tween_all_completed")
	is_open = false
	visible = false
	emit_signal("closed")
	queue_free()

func _on_Close_pressed():
	close()
