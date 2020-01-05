extends "res://interface/gui/player/AnimateBarBase.gd"

onready var thurst_bar := $ThurstBar

var is_exhausted

func initialize(metabolism_node:Node, stamina_node: Node) ->void:
	self.error = metabolism_node.connect('thurst_changed', self, '_on_player_thurst_changed')
	self.error = metabolism_node.connect('metabolism_rate_changed', self, '_on_player_metabolism_rate_changed')
	self.error = stamina_node.connect('player_exhausted', self, '_on_player_is_exhausted')
	_on_player_thurst_changed(metabolism_node.get_thurst())
	_on_player_metabolism_rate_changed(metabolism_node.IDLECALORIEBURN)
	_on_player_is_exhausted(stamina_node.is_exhausted)

func _on_player_thurst_changed(new_thurst:float) ->void:
	animate_bar(thurst_bar,new_thurst)

func _on_player_is_exhausted(_is_exhausted:bool) -> void:
	is_exhausted = _is_exhausted
	$Exhausted.visible = is_exhausted
	_on_player_metabolism_rate_changed(-$Metablolsim/ImpactBar.value)

func _on_player_metabolism_rate_changed(new_rate:float)->void:
	$Metablolsim/ImpactBar.value = -new_rate 
	if is_exhausted:
		$Metablolsim/ImpactBar.value *= 2
