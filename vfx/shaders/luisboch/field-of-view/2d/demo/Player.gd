extends KinematicBody2D

export var speed = 200
var move_control = Vector2()
var vel = Vector2()
var moving = false
export (NodePath) var danger_text_path
export (NodePath) var warn_text_path

onready var danger_txt = get_node(danger_text_path)
onready var warn_txt = get_node(warn_text_path)

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func check_fov():
	if danger_txt:
		danger_txt.text="Danger: "+str($field_of_view.in_danger_area)
	if warn_txt:
		warn_txt.text="Warn: "+str($field_of_view.in_warn_area)

func _process(delta):
	check_fov()
	var pos = get_position()
	var dir = (get_global_mouse_position() - pos).normalized()
	set_rotation(deg2rad(rad2deg(dir.angle()) - 90))

	
	# vel = Vector2()
	move_control = Vector2()

	moving = false
	if Input.is_key_pressed(KEY_A):
		move_control.x = 1
		moving = true
	elif Input.is_key_pressed(KEY_D):
		move_control.x = -1
		moving = true
	
	if Input.is_key_pressed(KEY_W):
		move_control.y = 1
		moving = true
	elif  Input.is_key_pressed(KEY_S): 
		move_control.y = -1
		moving = true
	
	vel = (move_control.normalized() * speed).rotated(transform.get_rotation())
	
	vel = move_and_slide(vel, Vector2())


