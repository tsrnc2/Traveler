#warning-ignore-all:unused_class_variable
extends Menu

onready var save_button = $Panel/Column/SaveButton
onready var load_button = $Panel/Column/LoadButton

# warning-ignore:unused_argument
func open(args={}):
	.open()
	save_button.grab_focus()
