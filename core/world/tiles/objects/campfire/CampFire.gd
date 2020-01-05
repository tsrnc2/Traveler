extends Area2D

signal open_npc_inventory

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in CampFire :", error)

export(bool) var is_on : bool = false
export(float) var ignite_time := 3.0

onready var inventory = $BlankInventory

func _ready()->void:
	$ActionProgress.set_action('Ignite')
	setup_settings()
	self.error = $AnimationPlayer.connect("animation_finished",self,'repeat_animation')
	self.error = $ActionProgress.connect("action_completed",self,'toggle_is_on')

func repeat_animation(_animation_name)->void:
	if is_on:
		$AnimationPlayer.play("on")

func toggle_is_on(is_completed:bool)->void:
	if is_completed:
		is_on = not is_on
	setup_settings()
	
func setup_settings()->void:
	if is_on:
		$AudioStreamPlayer2D.play()
		$CampFireSprite.animation = 'Fire'
		$AnimationPlayer.play('on')
		$Menu/Ignite.text = 'Extinguish'
		$ActionProgress.set_action('Eqtinguish')
	else:
		$AudioStreamPlayer2D.stop()
		$AnimationPlayer.play('off')
		$CampFireSprite.animation = 'Idle'
		$Menu/Ignite.text = 'Ignite'

func ignite()->void:
	if is_wood_avalable():
		$ActionProgress.perform_action(ignite_time)
	else:
		get_tree().get_nodes_in_group("InfoHUD")[0].display("Need wood to ignite")

func is_wood_avalable()->bool:
	if inventory.has('Wood'):
		return true
	return false

func show_menu()->void:
	$Menu.visible = true

func close_menu()->void:
	$Menu.visible = false

func _on_Close_pressed()->void:
	close_menu()

func _on_Ignite_pressed():
	ignite()
	close_menu()

func _on_CampFire_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			show_menu()

func _on_Inventory_pressed():
	emit_signal("open_npc_inventory",'Camp Fire', inventory)
