extends Node

var event_log = Array()

const MAX_EVENTS = 4

func initialize(element:Node)->void:
	element.connect("new_action",self,"add_event")
	
func add_event(new_event:String, cost := 0.0)->void:
	event_log.append(new_event + String(cost))
	while event_log.size() > MAX_EVENTS:
		event_log.pop_back()
		
func get_events() ->Array:
	return event_log
