extends "res://actors/Actor.gd"

signal visablity_changed

#var thread := Thread.new()

onready var sun_overlay :Node= get_tree().get_nodes_in_group("SunOverlay")[0]

const player_offset := Vector2(157.6,104.4)
const cell_size := Vector2(82,41)
var viewport_center_point : Vector2
signal open_map
signal open_sign_maker
signal flashlight_toggle
# warning-ignore:unused_signal
signal minigame

onready var camera :Camera2D= $Camera
onready var map_camera :Camera2D= $MapCamera
onready var state_machine :Node= $StateMachine
onready var anim_player :AnimationPlayer= $AnimationPlayer
onready var Body :AnimatedSprite= $BodyPivot/Body
onready var Wallet :Node= $Wallet
onready var Metabolism :Node= $Metabolism
onready var Stamina :Node= $Stamina
onready var Flashlight :Light2D= $LightPiviot/Flashlight
onready var Inventory :Node= $Inventory

#onready var nav2d : Navigation2D
#onready var line2d : Line2D 

var train: Node

# warning-ignore:unused_class_variable
export(int) var visablity := 3 setget set_visability# num of squares reviled in fog of war
#
#var current_path := PoolVector2Array() setget set_current_path
#
func _ready() -> void:
	viewport_center_point = Vector2( get_viewport().size.x/2, get_viewport().size.y/2) + player_offset
#	set_process(false)

func set_visability(new_visability)->void:
	visablity = new_visability
	if is_inside_tree():
		emit_signal("visablity_changed", visablity, global_position)

#func set_current_path(new_value: PoolVector2Array)->void:
#	current_path = new_value
#	if new_value.size() == 0:
#		print("Path is empty")
	
func initialize(target_global_position:Vector2, GameClock:Node) -> void:
	print('Loading Player')
	set_equipment()
	self.error = sun_overlay.connect("parts_of_day",self,"new_part_of_day")
	self.error = connect("flashlight_toggle", sun_overlay, "toggle_flashlight")
	new_part_of_day(sun_overlay.state)
	anim_player.play('SETUP')
	state_machine.start()
	Metabolism.start(GameClock,Stamina)
	Stamina.start()
	reset(target_global_position)
	train = get_tree().get_nodes_in_group("train")[0]
	self.error = train.connect("board_train",state_machine,"board_train")
	$EnvironmetalEffects.initialize(Inventory)
#	nav2d = get_tree().get_nodes_in_group('navigation')[0]
#	line2d = get_tree().get_nodes_in_group('line')[0]
#	thread = Thread.new()

func new_part_of_day(part:int)->void:
	match part:
		NIGHTCYCLE.DAY:
			if Flashlight.visible:
				toggle_flashlight()

func set_equipment() -> void:
	for item in Inventory.get_items():
		if item.type == ITEM_TYPE.EQUIPMENT:
			Inventory.set_equipment(item.name)

func reset(target_global_position) -> void:
	global_position = target_global_position
	anim_player.play('SETUP')
	camera.offset = Vector2()
	camera.current = true

func get_body() -> AnimatedSprite:
	return Body

func get_police_attention(police_source) -> void:
	if state_machine.current_state == $StateMachine/Stagger:
		return
	.get_police_attention(police_source)
	$StateMachine/Stagger.knockback_direction = (police_source.global_position - global_position).normalized()
	camera.shake = true

func move(velocity:Vector2) -> bool:
	#warning-ignore:return_value_discarded
	if	move_and_slide(velocity, Vector2(), 5, 2) and emit_signal("position_changed", global_position):
		return true
	return false
#	if get_slide_count() == 0:
#		return null
#	return get_slide_collision(0)
	
func fall(gap_size:Vector2) -> void:
	"""
	Interrupts the state machine and goes to the Fall state
	"""
	state_machine._change_state('fall')
	yield(state_machine.current_state, 'finished')
	move(-look_direction * gap_size * 1.5)

func _on_Die_finished(_string:String) ->void:
	set_dead(true)

func get_inventory() -> Node:
	return Inventory

func get_wallet() -> Node:
	return Wallet

func get_metabolism() -> Node:
	return Metabolism

func get_stamina() -> Node:
	return Stamina
	
func get_wanted_node() -> Node:
	return $WantedLevel

func get_camera() -> Camera2D:
	return camera
	
func get_animation_player() -> AnimationPlayer:
	return anim_player

func toggle_map()-> void:
	if camera.current:
		camera.clear_current()
		camera.current = false
		map_camera.current = true
	else:
		map_camera.clear_current()
		map_camera.current = false
		camera.current = true
	emit_signal("open_map", map_camera.current)

func _unhandled_input(event) -> void:
	if event.is_action_pressed("toggle_map"):
		toggle_map()
		get_tree().set_input_as_handled()
	if event.is_action_pressed("toggle_sign_maker"):
		emit_signal("open_sign_maker")
		get_tree().set_input_as_handled()
	if event.is_action_pressed('inventory'):
		emit_signal('open_inventory')
		get_tree().set_input_as_handled()
	if event.is_action_pressed("toggle_flashlight"):
		toggle_flashlight()
		get_tree().set_input_as_handled()
	if event.is_action("zoom_in"):
		camera.zoom_in(Vector2(0.01,0.01))
		get_tree().set_input_as_handled()
	if event.is_action("zoom_out"):
		camera.zoom_out(Vector2(0.01,0.01))
		get_tree().set_input_as_handled()
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			get_new_path(event)
#			get_tree().set_input_as_handled()

func toggle_flashlight()->void:
	Flashlight.visible = not Flashlight.visible
	if Flashlight.visible:
		emit_signal("flashlight_toggle", true)
		self.visablity += 2
	else:
		self.visablity -= 2
		emit_signal("flashlight_toggle", false)

func pulled_over():
	get_tree().get_nodes_in_group("PoliceStop")[0].open()

#func get_new_path(event:InputEvent)->void:
#	if is_click_outside_gameworld(event.global_position):
#		return
#	var relative_offset :Vector2= (event.global_position - viewport_center_point) 
#	var distance_to_realative_offset :float= Vector2(0,0).distance_to(relative_offset)
#	var global_offset :Vector2= relative_offset.normalized() * camera.zoom * distance_to_realative_offset
#	var target_position :Vector2 = global_position + global_offset
#	emit_signal("player_clicked_world",target_position)
##	if not thread.is_active():
##		self.error = thread.start(self, '_make_new_path', target_position)

#func is_click_outside_gameworld(test_position:Vector2):
#	if test_position.y > 980:
#		return true
#	return false

#func _make_new_path(target_position):
##	self.current_path = nav2d.call_deferred("get_simple_path",  global_position, target_position)
#	var new_path :PoolVector2Array = nav2d.get_simple_path(nav2d.get_closest_point(global_position),nav2d.get_closest_point(target_position) )
#	call_deferred("_set_new_path")
#	return new_path
#
#func _set_new_path() ->void:
#	print("setting new path")
#	self.current_path = thread.wait_to_finish()
#	line2d.points = current_path
