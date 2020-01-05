extends Area2D

func set_active(value):
	$CollisionShape2D.disabled = not value
	
func take_police_attenction(amount:int) -> void:
	.increase_wanted_level(amount)
