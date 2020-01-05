extends Node

const MAXWANTEDLEVEL = 100

signal wanted_level_changed(new_level)
signal wanted_level_maxed()

export(int) var wanted_level : = 0

func initialize()->void:
	emit_signal("wanted_level_changed", wanted_level)

func is_wanted() -> bool:
	return wanted_level >= MAXWANTEDLEVEL

func increase_wanted_level(amount:int):
	wanted_level += amount
	_check_for_max_level()
	emit_signal("wanted_level_changed", wanted_level)

func decrease_wanted_level(amount:int):
	wanted_level -= amount
	_check_for_max_level()
	emit_signal("wanted_level_changed", wanted_level)

func get_wanted_level():
	return wanted_level

func _check_for_max_level():
	if wanted_level > MAXWANTEDLEVEL:
		emit_signal("wanted_level_maxed")
		wanted_level = MAXWANTEDLEVEL
	elif wanted_level < 0:
		wanted_level = 0
