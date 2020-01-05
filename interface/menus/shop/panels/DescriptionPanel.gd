extends Control

# usefull so keep it here for copy paste
#get_tree().get_nodes_in_group("InfoHUD")[0].display("")

export(int) var MaxMessages = 4
export(Color) var DEFAULT_COLOR := Color('0004ff')

var discard_message := false
var MessageHistory : Array #StringArray does not work here as we want a actual array of strings not one big string
onready var tween = $Tween

var error :int = OK setget on_error

func on_error(new_error)->void:
	new_error = error
	if error != OK:
		print("Error inDescriptionPanel :", error)

func display(new_message: String, new_color : Color = DEFAULT_COLOR, new_discard := false) -> void:
	if new_message == $VBox/Description.text:
		return
	if not discard_message:
		MessageHistory.push_front($VBox/Description.text)
	discard_message = new_discard
	self.error = tween.interpolate_property($VBox/Description, 'custom_colors/font_color', DEFAULT_COLOR, new_color, 0, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	self.error =tween.start()
	$VBox/Description.text = new_message
	
	var i := 0
	var scroll_back_text : String
	for message_text in MessageHistory:
		if i > MaxMessages:
			MessageHistory.pop_back()
		else:
			scroll_back_text = message_text + '\n' + scroll_back_text
		i += 1
	$VBox/DescriptionHistory.text = scroll_back_text
