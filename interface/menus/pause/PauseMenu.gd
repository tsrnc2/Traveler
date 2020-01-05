# warning-ignore-all:unused_class_variable
extends Menu

signal unpause()

const PlayerController := preload("res://actors/player/PlayerController.gd")

onready var continue_button := $Background/Column/ContinueButton
onready var options_button := $Background/Column/OptionsButton
onready var save_button := $Background/Column/SaveButton

onready var buttons_container := $Background/Column

onready var save_menu := $SaveMenu
onready var options_menu := $OptionsMenu

func on_error(new_error:int) -> void:
	error = new_error
	if error != OK:
		print("Error in PauseMenu :", error)

func _ready() -> void:
	self.error = continue_button.connect("pressed",self,'close')
	self.error = options_button.connect('pressed', self, 'open_sub_menu', [options_menu])
	self.error = save_button.connect('pressed', self, 'open_sub_menu', [save_menu])
	remove_child(save_menu)
	remove_child(options_menu)

"""args: {actor}"""
func initialize(_args:Dictionary={}) -> void:
	pass
	
func close() -> void:
	emit_signal("unpause")
	.close()

func open(_args:Dictionary={}) ->void:
	.open()
	continue_button.grab_focus()

func open_sub_menu(menu, args:Dictionary={}) ->void:
	var last_focused_item = get_focus_owner()
	buttons_container.hide()
	yield(.open_sub_menu(menu, args), 'completed')
	buttons_container.show()
	last_focused_item.grab_focus()
	
func _on_QuitButton_pressed() ->void:
	get_tree().quit()
