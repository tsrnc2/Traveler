extends Area2D

var error :int=OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Police Vision :", error)

func initialize()->void:
		error = self.connect("body_entered",self,"_on_Vision_body_entered")

func set_active(value):
	$CollisionShape2D.disabled = not value

func _on_Vision_body_entered(body:Node):
	if body.is_in_group("suspect"):
		body.get_wanted_node().increase_wanted_level(owner.WANTED_LEVEL_INCREASE)
		if body.get_wanted_node().is_wanted():
			owner.pull_over(body)
		else:
			owner.warning(body)
