extends Control

signal new_suspision

enum STATES { START, STOP, PLAY }

var state :int= STATES.START setget change_state

onready var platform_animator := $Platform/PlatformAnimator
onready var vision_animator := $Path2D/PathFollow2D/VisionPoint/VisionAnimator
onready var player := $Player

onready var list_of_vision_animations :PoolStringArray 
onready var list_of_platform_animations :PoolStringArray 

var error :int= OK setget on_error

var suspision : int = 0 setget set_suspision

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("error in Balance MiniGame :", error)

func set_suspision(new_suspision:int)->void:
	suspision = new_suspision
	emit_signal("new_suspision",suspision)

func initialize(player_node:Node)-> void:
	print("loading minigame")
	randomize()
	$ColorRect.initialize()
	$Path2D.initialize()
	list_of_vision_animations = vision_animator.get_animation_list()
	list_of_platform_animations = platform_animator.get_animation_list()
	self.error = player_node.connect("minigame",self,"_on_minigame")
	suspision = 0
	self.error = vision_animator.connect("animation_finished",self,"_on_animation_finished")
	self.error = platform_animator.connect("animation_finished",self,"_on_animation_finished")
	$Meter.initialize(self)
	change_state(STATES.STOP)
	
func _on_minigame(is_active)->void:
	print("disabled minigame for now")
	return
	visible = is_active
	if visible:
		change_state(STATES.START)
	else:
		change_state(STATES.STOP)

func change_state(new_state:int)->void:
	match new_state:
		STATES.START:
			set_process(true)
			$Path2D.stop_moving(false)
			$ColorRect.run_color_animation(true)
			change_state(STATES.PLAY)
			return
		STATES.STOP:
			set_process(false)
			$Path2D.stop_moving(true)
			$ColorRect.run_color_animation(false)
#			vision_animator.play("stop")
#			platform_animator.play("stop")
		STATES.PLAY:
			vision_animator.play(get_next_vision_animaton())
			platform_animator.play("moving")
	state = new_state
	
func _on_animation_finished(_animation_name:String)->void:
	change_state(state)

func get_next_vision_animaton() -> String:
	return list_of_vision_animations[ randi() % (list_of_vision_animations.size()-1) ]

func get_next_platform_animaton() -> String:
	return list_of_vision_animations[ randi() % (list_of_vision_animations.size()-1) ]

func _unhandled_input(event:InputEvent)->void:
	if not visible:
		return
	if event.is_action("player_move_left"):
		player.linear_velocity += Vector2(-60,0)
		print("left button pressed")
	if event.is_action("player_move_right"):
		player.linear_velocity += Vector2(60,0)
		print("right button pressed")
	if event.is_action("player_move_down"):
		player.linear_velocity += Vector2(0,50)
		print("right button pressed")
	if event.is_action("jump"):
#		if is_on_ground():
		if player.linear_velocity.y > -100:
			player.linear_velocity += Vector2(0,-200)
			print("jump button pressed")

func _on_Close_pressed():
	change_state(STATES.STOP)
