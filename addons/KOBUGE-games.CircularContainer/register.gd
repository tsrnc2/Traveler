tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("CircularContainer", "Container", preload("CircularContainer.gd"), preload("icon.png"))
	print(self, preload("CircularContainer.gd"))

func _exit_tree():
	remove_custom_type("CircularContainer")
