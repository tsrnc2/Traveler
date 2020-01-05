extends "res://utils/state/State.gd"

export(int) var MAX_DISTANCE_FROM_TRAIN := 30 #pixels from train board point to be able to board

var boarding_point : Position2D

func set_boarding_point(new_boarding_point:Position2D)->void:
	boarding_point = new_boarding_point

func enter()->void:
	if !boarding_point:
		print("Error in PlayerState BoardTrain: no boarding point set")
		emit_signal("finished",'idle')
	var distance_to_train:Vector2 = Vector2(abs(owner.global_position.x - boarding_point.global_position.x),abs(owner.global_position.y - boarding_point.global_position.y))
	if distance_to_train.x > MAX_DISTANCE_FROM_TRAIN or distance_to_train.y > MAX_DISTANCE_FROM_TRAIN:
		get_tree().get_nodes_in_group("InfoHUD")[0].display("Must be closer to board")
		move_owner_to_bording_point()
	owner.get_animation_player().play('board')
	start_minigame()
#

func start_minigame()->void:
	owner.emit_signal("minigame",true)

func update(_delta)->void:
	owner.global_position = boarding_point.global_position
	owner.emit_signal("position_changed", owner.global_position)
	
func move_owner_to_bording_point()->void:
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(owner, 'position', owner.position, boarding_point.global_position, 0.1,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_all_completed")
	remove_child(tween)
	tween.queue_free()
	tween = null

func _on_animation_finished(_previous_state:String) ->void:
		emit_signal('finished', 'ridetrain')
