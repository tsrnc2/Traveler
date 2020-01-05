extends Area2D

func set_active(is_active:bool) -> void:
	$CollisionShape2D.disabled = not is_active
	$Light2D.visible = not is_active

func _on_Vision_body_entered(body):
	if body.is_in_group("donatable"):
		owner.donate(body)

