extends ColorRect
var error :int= OK setget on_error

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("error in MiniGame ColorChanger :", error)

func initialize()->void:
	visible = true
	self.error = $coloranimator.connect("animation_finished",self,"_on_animation_finished")

func run_color_animation(is_animation:bool)->void:
	if is_animation:
		$coloranimator.play("spectum")
	else:
		$coloranimator.stop(true)

func _on_animation_finished(_animation_name:String)->void:
	$coloranimator.play("spectum")
