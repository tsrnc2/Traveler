extends Node

signal player_exhausted
signal stamina_changed
signal max_stamina_changed
signal new_event

export(int) var REGENRATE : = 2 # per unit of REGENTIMEING
export(int) var REGENTIMING : = 1 #seconds
export(float) var EXHAUSTEDPENALTYMULTIPLYER : = 2
export(int) var EXHAUSTIONREMOVALPOINT := 60 
var _current_stamina :int = 100 
var _new_stamina :int = _current_stamina
var is_exhausted : = false
var _max_stamina : = 100
export(Color) var EXHAUSTEDINFOCOLOR : Color

var InfoPanel : Control

var current_event: String

func new_current_event(event_name:String, amount: = 0.0) ->void:
	if current_event != (event_name+ String(amount)):
		current_event = event_name + String(amount)
		emit_signal('new_event',current_event)

func start()->void:
	InfoPanel = get_tree().get_nodes_in_group("InfoHUD")[0]
	$RegenTimer.start(REGENTIMING)

func update_gui()->void:
	if _new_stamina == _current_stamina:
		return
	_current_stamina = _new_stamina
	emit_signal("stamina_changed",_current_stamina)

func boost_max_stamina(amount:int,event_name:String = '')->void:
	if event_name != '':
		new_current_event(event_name,amount)
	_max_stamina += amount
	emit_signal("max_stamina_changed",_max_stamina)
	
func reduce_max_stamina(amount:int,event_name:String = '')->void:
	if event_name != '':
		new_current_event(event_name,amount)
	_max_stamina -= amount
	emit_signal("max_stamina_changed",_max_stamina)

func take_stamina(amount:int, event_name:String = '') ->void:
	if event_name != '':
		new_current_event(event_name,amount)
	if is_exhausted:
		amount = int(amount * EXHAUSTEDPENALTYMULTIPLYER)
	#warning-ignore#narrowing_conversion
	_new_stamina = int(max(0, _current_stamina - amount))
	if _new_stamina == 0:
		is_exhausted = true
		InfoPanel.display("You feel exhausted\n You will need to rest before you can run again" , EXHAUSTEDINFOCOLOR)
		emit_signal("player_exhausted",is_exhausted)
	update_gui()	

func boost_stamina(amount:int, event_name:String = '') ->void:
	if event_name != '':
		new_current_event(event_name,amount)
	if is_exhausted:
		#warning-ignore:integer_division
		#warning-ignore#narrowing_conversion
		amount = int(amount / EXHAUSTEDPENALTYMULTIPLYER)
	#warning-ignore#narrowing_conversion
	_new_stamina = int(min(_max_stamina, _current_stamina + amount))
	if _new_stamina >= EXHAUSTIONREMOVALPOINT: 
		is_exhausted = false
		emit_signal("player_exhausted",is_exhausted)
	update_gui()
	
func _on_Timer_timeout()->void:
	boost_stamina(REGENRATE)
	$RegenTimer.start(REGENTIMING)

func get_stamina()->int:
	return _current_stamina
