extends RichTextLabel

export(Color) var DEFAULTCOLOR : Color
export(float) var DEFAULT_DISPLAY_TIME := 4.0 # Seconds

var error :int = OK setget on_error

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("Error in HookableQuotePanel :", error)

func initialize(actor:Node):
	visible = false
	set_text('')
	self.error = actor.connect("died", self, "_on_Actor_died")
	self.error = actor.connect("speaking", self, "_on_Actor_speaking")
	
func _on_Actor_died(_actor = null) ->void:
	queue_free()

func _on_Actor_speaking(new_text:String, _bar_color :Color = DEFAULTCOLOR, time :float = DEFAULT_DISPLAY_TIME) -> void:
	if new_text:
		visible = true
	else:
		visible = false
#TODO	 add stylebox override for color by copy and chaging then overriding the stylebox
	set_text(new_text)
	yield(get_tree().create_timer(time), "timeout")
	visible = false
