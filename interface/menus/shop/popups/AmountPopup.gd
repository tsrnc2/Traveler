extends Menu

signal amount_confirmed(value)

onready var popup = $Popup
onready var slider = $Popup/VBoxContainer/Slider/HSlider
onready var label = $Popup/VBoxContainer/Slider/Amount
onready var ok_button = $Popup/VBoxContainer/OkButton

#var error :int = OK setget on_error
#
func on_error(new_error)->void:
	new_error = error
	if error != OK:
		print("Error in AmountPopup :", error)

"""args: {value, max_value}"""
func initialize(args={}) -> void:
	error = ok_button.connect("pressed", self, "confirmed")
	assert(args.size() == 2)
	var value = args['value']
	var max_value = args['max_value']
	label.initialize(value, max_value)
	slider.initialize(value, max_value)
	slider.grab_focus()

func open(_args:Dictionary={}) -> void:
	popup.popup_centered()
	.open()
	yield(self, "amount_confirmed")
	.close()

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		confirmed(0)
		accept_event()
	elif event.is_action_pressed("ui_accept"):
		confirmed()
		accept_event()

func confirmed(value:int = slider.value) -> void:
	emit_signal("amount_confirmed", value)
