extends Menu

var tween : Tween

var open_position : Vector2
var close_position : Vector2

export var ANIMATION_TIME := 0.5
var tween_error = false setget on_tween_error

func on_tween_error(new_error:bool)->void:
	tween_error = new_error
	if tween_error != true:
		print("error in WantedLevelHUD tween:", tween_error)

"""args: {inventory}"""
func initialize(args:Dictionary={})->void:
	$HBox/EquipmentPanel.initialize(args['inventory'])
	$HBox/BackPack.initialize(args['inventory'])
	tween = Tween.new()
	add_child(tween)
	open_position = rect_position
	close_position = open_position - Vector2(150,800)

"""args: {inventory}"""
func open(args:Dictionary={}) ->void:
#	get_tree().paused = true
	assert args.size() == 1
#	var inventory = args['inventory']
	self.tween_error = tween.interpolate_property(self,'rect_position', close_position, open_position, ANIMATION_TIME,Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	self.tween_error = tween.start()
	.open()

func close() -> void:
#	get_tree().paused = false
	self.tween_error = tween.interpolate_property(self,'rect_position', open_position, close_position,ANIMATION_TIME/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	self.tween_error = tween.start()
	yield(tween,"tween_all_completed")
	.close()
	queue_free()

func _on_Button_pressed() -> void:
	close()

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed('inventory'):
		get_tree().set_input_as_handled()
		close()
