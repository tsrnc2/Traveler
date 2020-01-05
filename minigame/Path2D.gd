extends Path2D

onready var animator := $PathFollow2D/VisionPathAnimator

var error :int= OK setget on_error

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("error in MiniGame Path2D :", error)

func initialize()->void:
	self.error = animator.connect("animation_finished",self,"_animation_finished")
	
func stop_moving(is_not_moving:bool)->void:
	if is_not_moving:
		animator.play("holding")
	else:
		animator.play("moving")

func _animation_finished(animation_name:String) ->void:
	animator.play(animation_name)
