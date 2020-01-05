extends Node

signal new_event
signal hunger_changed(hunger)
signal thurst_changed(thurst)
signal metabolism_rate_changed(IDLECALORIEBURN)

const MAXHUNGER : = 100.0
const MAXTHURST : = 100.0
export(float) var CALORIESBURNRATE : = 1.0 # 1 is 100% of normal
export(float) var DEHIDRATIONRATE : = 1.0
export(float) var STARTHUNGER : = 60.0
export(float) var STARTTHURST : = 20.0
export(float) var CALORIESTOTHURSTPERCENT : = 0.25
export(float) var IDLECALORIEBURN : = -1.0 setget set_IDLECALORIEBURN

export(Color) var FOODINFOCOLOR : Color
export(Color) var WATERINFOCOLOR : Color

var _hunger : = STARTHUNGER
var _thurst : = STARTTHURST

var InfoPanel : Control

var error :int = OK setget on_error

var current_event: String

var is_exhaused : bool

func set_IDLECALORIEBURN(new_idleburn:float)->void:
	if IDLECALORIEBURN != new_idleburn:
		IDLECALORIEBURN = new_idleburn
		emit_signal("metabolism_rate_changed",IDLECALORIEBURN)

func new_current_event(event_name:String, amount: = 0.0) ->void:
	if current_event != (event_name+ String(amount)):
		current_event = event_name + String(amount)
		emit_signal('new_event',current_event)

func get_hunger()->float:
	return _hunger
	
func get_thurst()->float:
	return _thurst

func on_error(new_error)-> void:
	error = new_error
	if error != OK:
		print("Error in metabolism :", error )

func start(GameClock:Node, Stamina:Node) ->void:
	InfoPanel = get_tree().get_nodes_in_group("InfoHUD")[0]
	self.error = GameClock.connect('quarter_hour_update', self, '_on_quarter_hour')
	self.error = Stamina.connect("player_exhausted", self, 'on_player_exhaused')

func on_player_exhaused(_is_exhaused:bool)->void:
	is_exhaused = _is_exhaused

func metabolise(calories:float,event_name:String = '') ->void:
	eat(calories,event_name)
	dehidrate(calories*CALORIESTOTHURSTPERCENT,'Dehidedration from metabolising food ')

func dehidrate(amount:float,event_name:String = '') ->void:
	if event_name != '':
		new_current_event(event_name, amount)
	var new_thurst := _thurst - amount * DEHIDRATIONRATE
	if _thurst != check_for_max(new_thurst,MAXTHURST):
		_thurst = new_thurst
		emit_signal("thurst_changed",_thurst)

func hydrate(amount:float,event_name:String = '') ->void:
	if event_name != '':
		new_current_event(event_name,amount)
	var new_thurst := _thurst + amount * DEHIDRATIONRATE
	if _thurst != check_for_max(new_thurst,MAXTHURST):
		if _thurst < new_thurst:
			InfoPanel.display("You feel less thursty",WATERINFOCOLOR,false)
		_thurst = new_thurst
		InfoPanel.display("You feel less thursty",WATERINFOCOLOR,false)
		emit_signal("thurst_changed",_thurst)

func eat(calories:float,event_name:String = '') ->void:
	if event_name != '':
			new_current_event(event_name,calories)
	var new_hunger := _hunger + calories * CALORIESBURNRATE
	if _hunger != check_for_max(new_hunger,MAXHUNGER):
		if _hunger < new_hunger:
			InfoPanel.display("You feel less hungry",FOODINFOCOLOR,false)
		_hunger = new_hunger
		emit_signal("hunger_changed",_hunger)

#warning-ignore:narrowing_conversion
func check_for_max(value:float, maxvalue:float) -> float:
	var newvalue = max(value,0)
	return min(newvalue, maxvalue)

func _on_quarter_hour() -> void:
	if is_exhaused: #double metabolise if exhaused
		metabolise(IDLECALORIEBURN)
	metabolise(IDLECALORIEBURN)
