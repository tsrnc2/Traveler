extends Area2D

func set_active(value):
	$CollisionShape2D.disabled = not value
	
func take_police_attention(amount:int) -> void:
	.increase_wanted_level(amount)

#func _on_DamageSource_body_entered(_body) -> void:
#	take_police_attention(get_parent().police_attention_level)
