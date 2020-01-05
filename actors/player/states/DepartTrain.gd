extends "res://utils/state/State.gd"

var offset:= Vector2(0,-35)

func enter()->void:
	move_owner_to_depart()
	owner.get_animation_player().play("depart")
	owner.emit_signal("minigame",false)

func update(_delta)->void:
	pass

func _on_animation_finished(_previous_state:String) ->void:
	emit_signal("finished", 'idle')

func move_owner_to_depart()->void:
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(owner, 'position', owner.position, owner.global_position + offset, 0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_all_completed")
	remove_child(tween)
	tween.queue_free()
	tween = null
