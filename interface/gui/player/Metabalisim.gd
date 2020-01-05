extends HBoxContainer

#export(PackedScene) var PlayerOverview := preload("res://interface/menus/overviews/PlayerOverview.tscn")

#var Overview_Pointer: Node

export var GROW_PERCENT = 3

var current_hunger : = 0
var current_thurst : = 0
var current_stamina : = 0
var is_exhausted : = false

var PlayerOverview : Control

var error :int=OK setget on_error
	
func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("Error in PlayerOverview : ", error)

func initialize(metabolism_node:Node,stamina_node:Node, _PlayerOverview:Control) ->void:
	PlayerOverview = _PlayerOverview
	current_hunger = metabolism_node._hunger
	current_thurst = metabolism_node._thurst
	current_stamina = stamina_node.get_stamina()
	self.error = metabolism_node.connect('hunger_changed', self, '_on_player_hunger_changed')
	self.error = metabolism_node.connect('thurst_changed', self, '_on_player_thurst_changed')
	self.error = stamina_node.connect('stamina_changed', self, '_on_player_stamina_changed')
	self.error = stamina_node.connect('player_exhausted', self, 'is_player_exhausted')
	_on_player_hunger_changed(current_hunger)
	_on_player_thurst_changed(current_thurst)
	_on_player_stamina_changed(current_stamina)

func is_player_exhausted(new_value:bool) ->void:
	is_exhausted = new_value

func _on_player_hunger_changed(new_hunger:int) ->void:
	animate_hunger_bar(new_hunger)
	current_hunger = new_hunger

func _on_player_thurst_changed(new_thurst:int) ->void:
	animate_thurst_bar(new_thurst)
	current_thurst = new_thurst

func _on_player_stamina_changed(new_stamina:int) ->void:
	animate_stamina_bar(new_stamina)
	current_stamina = new_stamina

func animate_hunger_bar(target_hunger:int) ->void:
	if (not PlayerOverview.is_open) and ((current_hunger - target_hunger > 5) or (current_hunger < target_hunger) or current_hunger < 10):
		$HungerPanel/HungerBar.animate_size_and_bounce(GROW_PERCENT,75)
	$HungerPanel/HungerBar.animate_value(current_hunger, target_hunger)
	$HungerPanel/HungerBar.update_color(target_hunger)

func animate_thurst_bar(target_thurst:int) ->void:
	if (not PlayerOverview.is_open) and ((current_thurst - target_thurst > 5) or (current_thurst < target_thurst) or current_thurst < 10):
		$ThurstPanel/ThurstBar.animate_size_and_bounce(GROW_PERCENT,75)
	$ThurstPanel/ThurstBar.animate_value(current_thurst, target_thurst)
	$ThurstPanel/ThurstBar.update_color(target_thurst)
	
func animate_stamina_bar(target_stamina:int) ->void:
	if (not PlayerOverview.is_open) and ((current_stamina - target_stamina > 5) or current_stamina < 15):
		$StaminaPanel/Stamina.animate_size_and_bounce(GROW_PERCENT,75)
	$StaminaPanel/Stamina.animate_value(current_stamina, target_stamina)
	$StaminaPanel/Stamina.update_color(target_stamina,is_exhausted)

func _on_mouse_entered() ->void:
#	if Overview_Pointer:
#		return
#	var new_overview := PlayerOverview.instance()
#	add_child(new_overview)
#	new_overview.initialize()
#	Overview_Pointer = new_overview
	PlayerOverview.show()

func _on_mouse_exited() ->void:
	PlayerOverview.close()
#	if not Overview_Pointer:
#		return
#	Overview_Pointer.close()
#	yield(Overview_Pointer,"closed")
#	if not Overview_Pointer:
#		return
#	Overview_Pointer.queue_free()
#	Overview_Pointer = null
