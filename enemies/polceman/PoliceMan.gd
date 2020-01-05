# warning-ignore-all:unused_class_variable
extends "res://enemies/CopBase.gd"

signal initialize_stop

enum STATES{ IDLE, ROAM, RETURN, SPOT, FOLLOW, STAGGER, PREPARE_TO_CHARGE, CHARGE, BUMP, BUMP_COOLDOWN, HIT_PLAYER_COOLDOWN, DIE, DEAD}

export(float) var MAX_ROAM_SPEED := 50.0
export(float) var MAX_FOLLOW_SPEED := 125.0
export(float) var MAX_CHARGE_SPEED := 200.0

export(float) var SPOT_RANGE := 160.0
export(float) var FOLLOW_RANGE := 200.0
export(float) var BUMP_RANGE := 10.0

export(float) var CHARGE_RANGE := 75.0
export(float) var PREPARE_TO_CHARGE_WAIT_TIME := 0.9
export(float) var CHARGE_DISTANCE := 50.0

onready var body_pivot :Node= $BodyPivot
onready var police_lights :Node= $PoliceLights
onready var anim_player :Node= $AnimationPlayer

var tween : Tween
var timer : Timer

var FRAME_ACTIONS = {IDLE = "Idle", SHOT = "Shot", WALK = "Walk"}
var frame_action: String = FRAME_ACTIONS.WALK

var charge_direction := Vector2()
var charge_distance := 0.0

export(float) var ROAM_RADIUS := 140.0

var roam_target_position := Vector2()
var roam_slow_radius := 0.0

export(float) var BUMP_DISTANCE := 10.0
export(float) var BUMP_DURATION := 0.2
export(float) var MAX_BUMP_HEIGHT := 50.0

export(float) var BUMP_COOLDOWN_DURATION := 0.6

func on_error(new_error:int) -> void:
	error = new_error
	if error != OK:
		print ("Error in PoliceMan :", error)

func initialize(target_actor):
#	self.initialize(target_actor)
	if not target_actor is Actor:
		return
	target = target_actor
	self.error = target.connect('died', self, '_on_target_died')
	set_active(true)
	self.error = connect('initialize_stop',target,'pulled_over')
	make_helpers()
	$BodyPivot.initialize()
	$exclamation_mark.visible = false
	if not anim_player:
		anim_player = get_node("AnimationPlayer")
	self.error = tween.connect('tween_completed', self, '_on_tween_completed')
	self.error = anim_player.connect('animation_finished', self, '_on_animation_finished')
	self.error = timer.connect('timeout', self, '_on_Timer_timeout')
	$AnimatedSprite.playing = true
	_change_state(STATES.IDLE)
	
func make_helpers()-> void:
	tween = Tween.new()
	add_child(tween)
	timer = Timer.new()
	add_child(timer)

func _change_state(new_state):
	if not active:
		return
	match state:
		STATES.IDLE:
			timer.stop()
		STATES.CHARGE:
			police_lights.emitting = true
		STATES.FOLLOW:
			police_lights.emitting = true
	match new_state:
		STATES.IDLE:
			randomize()
			timer.wait_time = randf() * 2 + 1.0
			timer.start()
			frame_action = FRAME_ACTIONS.IDLE
		STATES.ROAM:
			randomize()
			var random_angle = randf() * 2 * PI
			randomize()
			var random_radius = (randf() * ROAM_RADIUS) / 2 + ROAM_RADIUS / 2
			roam_target_position = start_position + Vector2(cos(random_angle) * random_radius, sin(random_angle) * random_radius)
			roam_slow_radius = roam_target_position.distance_to(start_position) / 2
			frame_action = FRAME_ACTIONS.WALK
		STATES.STAGGER:
			anim_player.play("stagger")
			frame_action = FRAME_ACTIONS.IDLE
		STATES.SPOT:
			anim_player.play('spot')
			frame_action = FRAME_ACTIONS.IDLE
			.speak("I got my eye on you\n")
		STATES.PREPARE_TO_CHARGE:
			timer.wait_time = PREPARE_TO_CHARGE_WAIT_TIME
			timer.start()
			frame_action = FRAME_ACTIONS.IDLE
			.speak("Stop right there\n")
		STATES.CHARGE:
			if not target:
				return
			charge_direction = (target.position - position).normalized()
			charge_distance = 0.5
			police_lights.emitting = true
			frame_action = FRAME_ACTIONS.SHOT
			.speak("\n")
			emit_signal('initialize_stop')
		STATES.BUMP:
			print("bump")
			anim_player.stop()
			police_lights.emitting = true
			var bump_direction := - velocity.normalized()
#			self.error = int(tween.interpolate_property(self, 'position', position, position + BUMP_DISTANCE * bump_direction, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN))
#			self.error = int(tween.interpolate_method(self, '_animate_bump_height', 0, 1, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN))
#			self.error = int(tween.start())
			move(bump_direction * BUMP_DISTANCE)
			frame_action = FRAME_ACTIONS.WALK
			.speak('...')
#			.speak("Open Fire\n")
		STATES.BUMP_COOLDOWN:
			randomize()
			police_lights.emitting = true
			frame_action = FRAME_ACTIONS.IDLE
			self.error= get_tree().create_timer(BUMP_COOLDOWN_DURATION).connect('timeout', self, '_change_state', [STATES.FOLLOW])
		STATES.DEAD:
			anim_player.play("die")
			set_active(false)
			yield(anim_player, "animation_finished")
			emit_signal("died",self)
			queue_free()
		STATES.FOLLOW:
			police_lights.emitting = true
			frame_action = FRAME_ACTIONS.WALK
	state = new_state

func _physics_process(delta):
	var current_state = state
	match current_state:
		STATES.IDLE:
			if not target:
				return
			if position.distance_to(target.position) < SPOT_RANGE:
				_change_state(STATES.SPOT)
			update_sprite()
		STATES.ROAM:
			velocity = Steering.arrive_to(velocity, position, roam_target_position, roam_slow_radius, MAX_ROAM_SPEED)
			move(velocity)
			if position.distance_to(roam_target_position) < ARRIVE_DISTANCE:
				_change_state(STATES.IDLE)
			if not target:
				return
#			elif position.distance_to(target.position) < SPOT_RANGE:
#				_change_state(STATES.SPOT)
			update_sprite()
		STATES.RETURN:
			velocity = Steering.arrive_to(velocity, position, start_position, roam_slow_radius, MAX_ROAM_SPEED)
			move(velocity)
			if position.distance_to(start_position) < ARRIVE_DISTANCE:
				_change_state(STATES.IDLE)
			elif not target:
				return
			elif position.distance_to(target.position) < SPOT_RANGE:
				_change_state(STATES.SPOT)
			update_sprite()
		STATES.FOLLOW:
			if not target:
				_change_state(STATES.RETURN)
				return
			velocity = Steering.follow(velocity, position, target.position, MAX_FOLLOW_SPEED)
			move(velocity)

			if position.distance_to(target.position) < CHARGE_RANGE:
				_change_state(STATES.PREPARE_TO_CHARGE)

			if position.distance_to(target.position) > FOLLOW_RANGE:
				_change_state(STATES.RETURN)
			update_sprite()
		STATES.CHARGE:
			if charge_distance > CHARGE_DISTANCE or not target:
				_change_state(STATES.BUMP_COOLDOWN)
				return

			velocity = charge_direction * MAX_CHARGE_SPEED
			velocity = charge_direction * MAX_CHARGE_SPEED
			charge_distance += velocity.length() * delta
			if move(velocity):
				_change_state(STATES.IDLE)
			update_sprite()

func update_sprite() -> void:
	var angle := velocity.angle()
	$BodyPivot.rotation = angle
	var next_frame :String = get_next_frame(rad2deg(angle))
	if not $AnimatedSprite.animation == next_frame:
		$AnimatedSprite.play(next_frame)
		if ($AnimatedSprite.is_playing() == false):
			print("error in CopCar AnimatedSprite playing :", next_frame)
	
func move(velocity:Vector2)-> void:

# warning-ignore:return_value_discarded
	move_and_slide(velocity)

	
func get_next_frame(angle) -> String:
	return frame_action + String(direction_number(angle))

func direction_number(check_angle: float) -> int:
	#angle from -180 to 180 degres 0 is x+ axis
	if check_angle >= -22.5  and check_angle < 22.5:
		return 1
	elif check_angle >= 22.5  and check_angle < 67.5:
		return 0
	elif check_angle >= 67.5  and check_angle < 112.5:
		return 7
	elif check_angle >= 112.5  and check_angle < 157.5:
		return 6
	elif check_angle >= 157.5  or check_angle < -157.5:
		return 5
	elif check_angle <= -112.5  and check_angle > -157.5:
		return 4
	elif check_angle <= -67.5  and check_angle > -112.5:
		return 3
	elif check_angle <= -22.5  and check_angle > -67.5:
		return 2
		
	print("error in PoliceMan direction. angle :", check_angle)
	self.error = -1
	return error #if you here you made a booboo

func _on_animation_finished(anim_name:String) ->void:
	match anim_name:
		'spot':
			if target.get_wanted_node().is_wanted():
				_change_state(STATES.FOLLOW)
			else:
				_change_state(STATES.ROAM)
		'stagger':
			_change_state(STATES.IDLE)
		_:
			_change_state(STATES.IDLE)

func _animate_bump_height(progress:float) -> void:
	body_pivot.position.y = -pow(sin(progress * PI), 0.4) * MAX_BUMP_HEIGHT

func _on_tween_completed(_object:Object, _key:NodePath) ->void:
	_change_state(STATES.BUMP_COOLDOWN)

func _on_Timer_timeout() ->void:
	match state:
		STATES.IDLE:
			_change_state(STATES.ROAM)
		STATES.PREPARE_TO_CHARGE:
			_change_state(STATES.CHARGE)
			
func pull_over(_target:Node) -> void:
	if target == _target:
		InfoHUB.display(PULLOVER_MESSAGE,MESSAGECOLOR)
		_change_state(STATES.FOLLOW)
		
func warning(_target:Node)->void:
	if target == _target:
		speak(WARNING_MESSAGE)
