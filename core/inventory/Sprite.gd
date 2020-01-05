extends Sprite

onready var timer = $Timer
var adjestment :int = 0

export(float) var ANIMATION_SPEED := 0.3

func open_box():
	adjestment = 1
	timer.start(ANIMATION_SPEED)
	
func close_box():
	adjestment = -1
	timer.start(ANIMATION_SPEED)
	
func _on_Timer_timeout():
	if frame == 0 and adjestment == -1:
		adjestment = 0
	if frame == 3 and adjestment == 1:
		adjestment = 0
	if frame + adjestment > -1 && frame + adjestment < 3:
		frame += adjestment 
	if not adjestment == 0:
		timer.start(0.1)
