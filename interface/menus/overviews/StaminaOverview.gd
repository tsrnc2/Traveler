extends "res://interface/gui/player/AnimateBarBase.gd"

onready var stamina_bar := $StaminaBar

func initialize(stamina_node:Node) ->void:
	self.error = stamina_node.connect('stamina_changed', self, '_on_player_stamina_changed')
	self.error = stamina_node.connect('player_exhausted', self, '_on_player_is_exhausted')
	_on_player_stamina_changed(stamina_node.get_stamina())
	_on_player_is_exhausted(stamina_node.is_exhausted)
	$EventLog.initialize(stamina_node)

func _on_player_stamina_changed(new_stamina:int) ->void:
	animate_bar(stamina_bar,new_stamina)
	
func _on_player_is_exhausted(is_exhausted:bool) -> void:
	$Exhausted.visible = is_exhausted
