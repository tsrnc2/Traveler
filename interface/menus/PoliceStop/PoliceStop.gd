extends Control

onready var animation_player = $AnimationPlayer

func _ready()->void:
	animation_player.play('init')

func open()->void:
	print('Opening Police Stop Panel')
	get_tree().paused = true
	animation_player.play("open")
	if not animation_player.is_playing():
		print('Error in PoliceStop Animator')

func close()->void:
	animation_player.play('close')
	get_tree().paused = false

func _on_ItemList_item_selected(index:int)->void:
	perform_action(index)

func perform_action(_index:int)->void:
	close()
