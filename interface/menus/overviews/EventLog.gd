extends Label

var event_log = Array()

const MAX_EVENTS = 3

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in EventLog :",self.name, " error code :", error)

func initialize(element:Node)->void:
	self.error = element.connect("new_event",self,"add_event")
	
func add_event(new_event:String, cost := 0.0)->void:
	event_log.append(new_event + String(cost))
	while event_log.size() > MAX_EVENTS:
		event_log.pop_back()
	display_events()
		
func get_events() ->Array:
	return event_log

func display_events()->void:
	var new_text := String()
	for event in event_log:
		new_text += event + '\n'
	text = new_text
