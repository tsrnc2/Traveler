#warning-ignore-all:unused_class_variable
extends Control
class_name Menu

signal open()
signal closed()

export(NodePath) var SUB_MENU_PATH

onready var sound_confirm = $MenuSfx/Confirm
onready var sound_navigate = $MenuSfx/Navigate
onready var sound_open = $MenuSfx/Open

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	if new_error != OK:
		print("Error in ", self.name, " Error code :", new_error)
	error = new_error

func _ready() -> void:
	set_process_input(false)

# warning-ignore:unused_argument
func open(args:Dictionary={}) -> void:
	set_process_input(true)
	show()
	sound_open.play()
	emit_signal("open")

func close() -> void:
	sound_confirm.play()
	set_process_input(false)
	hide()
	emit_signal("closed")

func _gui_input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		accept_event()
		close()

# You can streamline opening sub menus with these methods
# The main drawback is you lose the initialize method's signature
# Instead you have to group the arguments in a dictionary

# warning-ignore:unused_argument
func initialize(args:Dictionary={}) ->void:
	return

func open_sub_menu(menu, args:Dictionary={}) ->void:
	var sub_menu = menu.instance() if menu is PackedScene else menu
	if SUB_MENU_PATH:
		get_node(SUB_MENU_PATH).add_child(sub_menu)
	else:
		add_child(sub_menu)
	sub_menu.initialize(args)

	set_process_input(false)
	sub_menu.open(args)
	yield(sub_menu, "closed")
	set_process_input(true)
	remove_child(sub_menu)
