extends Sprite

enum DIRECTION {SW = 40,SE = 30 ,NE = 20,NW = 10} #COLLUM
enum SHIRT_COLOR {BLUE = 0, GREEN =1*40, GRAY =2*40, WHITE=3*40, RED=4*40, PURPLE=5*40, BROWN=6*40} #ROW
enum PERFESION {GENERIC=0, DOCTOR=11, PERFESIONAL=22, ATLETIC=17} # ROW
enum ACTION {WALK=0, SIT=9}

var direction = DIRECTION.SW setget set_direction
var shirt = SHIRT_COLOR.BLUE setget set_shirt
var action = ACTION.WALK setget set_action

var curent_animation : Vector2

const ANIMATION_SPEED := 0.1 # secs between frames
var timer : float = 0

func _process(delta)->void:
	timer += delta
	if timer >= ANIMATION_SPEED:
		timer = 0
		display_next_frame()

func set_action(new_action:int) ->void:
	action = new_action
	set_current_animation()
	
func set_direction(new_direction:int)->bool:
	if direction == new_direction:
		return false
	direction = new_direction
	set_current_animation()
	return true
	
func get_direction()->int:
	return direction
	
func set_shirt(new_shirt_color:int)->void:
	shirt = new_shirt_color
		
func set_current_animation() ->void:
	var start_animation = shirt + direction + action
	var end_animation = shirt + direction + action + get_end_frame()
	curent_animation = Vector2(start_animation,end_animation)
	
func display_next_frame()->void:
	frame = get_next_frame()

func get_next_frame()->int:
	var next_frame = frame + 1
	if next_frame > curent_animation.y:
		next_frame = curent_animation.x
	return next_frame
	
func get_end_frame() -> int:
	if action == ACTION.WALK:
		return 9
	return 0
