extends KinematicBody2D
enum ITEM_TYPE {EQUIPMENT = 0, FOOD = 1, CLOTHING = 2, RESORCE = 3}

enum NIGHTCYCLE {
	MORNING = 0,
	DAY = 1,
	NIGHT =2
}
#warning-ignore-all:unused_signal
signal direction_changed(new_direction)
signal position_changed(new_position)
signal died()
signal open_inventory()

var look_direction = Vector2(1, 0) setget set_look_direction

var error :int= OK setget on_error

func on_error(new_error:int) ->void:
	error = new_error
	if error != OK:
		print("Error in actor named:",self.name, "Error :", error)

func set_dead(isvalue: bool) -> void:
	set_process_input(not isvalue)
	set_physics_process(not isvalue)
	emit_signal('died')

func set_look_direction(value: Vector2) -> void:
	if not look_direction == value:
		look_direction = value
		emit_signal("direction_changed", value)
