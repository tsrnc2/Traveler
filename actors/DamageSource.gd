
extends Area2D

export(int) var attention = 2
var effect

func set_active(value):
	$CollisionShape2D.disabled = not value
