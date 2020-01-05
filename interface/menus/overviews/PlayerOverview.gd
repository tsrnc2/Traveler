extends NinePatchRect

export(float) var ANIMATION_TIME := 1

onready var hunger_panel = $VBoxContainer/HungerOverview
onready var thurst_panel = $VBoxContainer/ThurstOverview
onready var stamina_panel = $VBoxContainer/StaminaOverview

var tween : Tween

var error :bool=true setget on_tween_error

func on_tween_error(new_error:bool)->void:
	error = new_error
	if error != true:
		print("error in Player Overview tween :", error)

var open_rotation:float
var close_rotation:float

var open_position:Vector2
var close_position:Vector2

var is_open := false

onready var metabolism_event_log : = $VBoxContainer/EventLogNote/MetablismEventLog

func initialize(metabolism_node :Node,stamina_node :Node)->void:
	hunger_panel.initialize(metabolism_node,stamina_node)
	thurst_panel.initialize(metabolism_node,stamina_node)
	stamina_panel.initialize(stamina_node)
	metabolism_event_log.initialize(metabolism_node)

	visible = false
	tween = Tween.new()
	add_child(tween)
	open_rotation = 0
	close_rotation = -100
	open_position = rect_position
	close_position = open_position - Vector2(100,100)
	
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

func _on_Button_pressed():
	close()
