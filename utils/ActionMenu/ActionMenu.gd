extends Control

onready var circle_menu := $CircularContainer
#eample action_list = {"button-text","function name"}
var error :int =OK setget on_error

func on_error(new_error)->void:
	error = new_error
	if error != OK:
		print("Error in ActionMenu :", error)
		
func _ready()->void:
	close_menu()

func initialize(action_list:Dictionary = {},_signal_connector:Node = get_parent()) -> void:
	if action_list.empty():
		print("Error in ActionMenu empty action list")
	for action in action_list.keys():
		var new_button = Button.new()
		new_button.text = action
		circle_menu.add_child(new_button)
		self.error = new_button.connect("pressed",_signal_connector,action_list.get(action))
	add_close_button()
	circle_menu.set_display_all_at_once(true)

func add_close_button(is_add:bool = true)->void:
	if not is_add:
		return
	var close_button = Button.new()
	close_button.text = "Close"
	circle_menu.add_child(close_button)
	self.error = close_button.connect("pressed",self,"_on_Close_pressed")

func show_menu() ->void:
	visible = true

func close_menu()->void:
	visible = false

func _on_Close_pressed():
	close_menu()

func clear_menu()->void:
	for child in circle_menu.get_children():
		circle_menu.remove_child(child)
		child.queue_free()
