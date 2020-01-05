tool
extends Container

## Properties ##
var _force_squares = false setget _private_set, _private_get
var _force_expand = false setget _private_set, _private_get
var _start_angle = 0 setget _private_set, _private_get
var _percent_visible = 1 setget _private_set, _private_get
var _appear_at_once = false setget _private_set, _private_get
var _allow_node2d = false setget _private_set, _private_get
var _start_empty = false setget _private_set, _private_get
var _custom_animator_func = null setget _private_set, _private_get

## Cached variables ##
var _cached_min_size_key = "" setget _private_set, _private_get
var _cached_min_size = null setget _private_set, _private_get
var _cached_min_size_dirty = false setget _private_set, _private_get

## Callbacks ##

var error :int=OK setget on_error

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print('Error in CircularContainer')

func _ready():
	self.error = connect("sort_children", self, "_resort")
	_resort()

## Properties / Public API ##

func set_custom_animator(object, method): # Params of animator function : node (Control or Node2D), center_pos, target_pos, time (0..1)
	_custom_animator_func = funcref(object, method)
func unset_custom_animator():
	_custom_animator_func = null

func set_force_squares(enable):
	_force_squares = bool(enable)
	_resort();

func is_force_squares_enabled():
	return _force_squares

func set_force_expand(enable): 
	_force_expand = bool(enable)
	_resort()

func is_force_expand_enabled():
	return _force_expand

func set_start_angle(rad):
	_start_angle = float(rad)
	_resort()
	
func get_start_angle():
	return _start_angle

func set_start_angle_deg(angle):
	_start_angle = deg2rad(float(angle))
	_resort()

func get_start_angle_deg():
	return rad2deg(_start_angle)

func set_percent_visible(percent):
	_percent_visible = clamp(float(percent), 0, 1)
	_resort()

func get_percent_visible():
	return _percent_visible

func set_display_all_at_once(enable):
	_appear_at_once = bool(enable)
	_resort()

func is_display_all_at_once():
	return _appear_at_once

func set_allow_node2d(enable):
	_allow_node2d = bool(enable)
	_resort()
	
func is_allowing_node2d():
	return _allow_node2d

func set_start_empty(enable):
	_start_empty = bool(enable)
	_resort()

func is_start_empty():
	return _start_empty

func _get_minimum_size():
	if _cached_min_size == null:
		_cached_min_size_dirty = true
		_update_cached_min_size()
	return _cached_min_size

func _get_property_list():
	return [
		{usage = PROPERTY_USAGE_CATEGORY, type = TYPE_NIL, name = "CircularContainer"},
		{type = TYPE_BOOL, name = "arrange/force_squares"},
		{type = TYPE_BOOL, name = "arrange/force_expand"},
		{type = TYPE_REAL, name = "arrange/start_angle", hint = PROPERTY_HINT_RANGE, hint_string = "-1080,1080,0.01"},
		{type = TYPE_BOOL, name = "arrange/start_empty"},
		{type = TYPE_BOOL, name = "arrange/allow_node2d"},
		{type = TYPE_REAL, name = "animate/percent_visible", hint = PROPERTY_HINT_RANGE, hint_string = "0,1,0.01"},
		{type = TYPE_BOOL, name = "animate/all_at_once"}
	]

func _set(property, value):
	if property == "arrange/force_squares": set_force_squares(value)
	if property == "arrange/force_expand": set_force_expand(value)
	elif property == "arrange/start_angle": set_start_angle_deg(value)
	elif property == "arrange/start_empty": set_start_empty(value)
	elif property == "arrange/allow_node2d": set_allow_node2d(value)
	elif property == "animate/percent_visible": set_percent_visible(value)
	elif property == "animate/all_at_once": set_display_all_at_once(value)
	else:
		return false
	
	return true # When return false doesn't happen

func _get(property):
	if property == "arrange/force_squares": return _force_squares
	if property == "arrange/force_expand": return _force_expand
	elif property == "arrange/start_angle": return rad2deg(_start_angle)
	elif property == "arrange/start_empty": return _start_empty
	elif property == "arrange/allow_node2d": return _allow_node2d
	elif property == "animate/percent_visible": return _percent_visible
	elif property == "animate/all_at_once": return _appear_at_once

## Main Logic ##

func _resort():
	var rect = get_rect()
	var origin = rect.size / 2
	
	var children = _get_filtered_children()
	
	if children.size() == 0:
		return
		
	var min_child_size = Vector2()
	for child in children:
		var size = _get_child_min_size(child)
		min_child_size.x = max(min_child_size.x, size.x)
		min_child_size.y = max(min_child_size.y, size.y)
	
	var radius = min(rect.size.x - min_child_size.x, rect.size.y - min_child_size.y) / 2
	
	if !_cached_min_size_dirty:
		call_deferred("_update_cached_min_size")
		_cached_min_size_dirty = true # Prevent double-queueing
	
	var angle_required = 0
	var total_stretch_ratio = 0
	var angle_for_child = []
	for child in children:
		var angle = _get_max_angle_for_diagonal(_get_child_min_size(child).length(), radius)
		angle_required += angle
		angle_for_child.push_back(angle)
		total_stretch_ratio += _get_child_stretch_ratio(child)
	
	if total_stretch_ratio > 0: # Division by zero otherwise
		for i in range(children.size()): 
			var child = children[i]
			angle_for_child[i] += (2 * PI - angle_required) * _get_child_stretch_ratio(child) / total_stretch_ratio
	
	var angle_reached = _start_angle
	if !_start_empty:
		angle_reached -= angle_for_child[0] / 2
	
	var appear = _percent_visible
	if !_appear_at_once:
		appear *= children.size()
	
	for i in range(children.size()):
		var child = children[i]
		_put_child_at_angle(child, radius, origin, angle_reached, angle_for_child[i], clamp(appear, 0, 1))
		angle_reached += angle_for_child[i]
		if !_appear_at_once:
			appear -= 1

func _put_child_at_angle(child, radius, origin, angle_start, angle_size, appear):
	var size = _get_child_min_size(child)
	var target = Vector2(0,-radius).rotated(-(angle_start + angle_size/2)) + origin
	
	if child is Control:
		child.set_size(size)
	
	if _custom_animator_func != null:
		_custom_animator_func.call_func(child, origin, target, appear)
	else:
		_default_animator(child, origin, target, appear)

func _update_cached_min_size():
	if !_cached_min_size_dirty:
		return
	_cached_min_size_dirty = false
	
	var children = _get_filtered_children()
	
	if children.size() == 0:
		return
	
	var min_radius = 1
	var min_child_size = Vector2()
	var max_radius = 1
#	var test = 1
	var diagonals = []
	for child in children:
		var size = _get_child_min_size(child)
		min_child_size.x = max(min_child_size.x, size.x)
		min_child_size.y = max(min_child_size.y, size.y)
		var diagonal = size.length()
		min_radius = max(min_radius, diagonal / 2)
		max_radius += diagonal / 2
		diagonals.push_back(diagonal)
	
	var key = str(diagonals)
	if _cached_min_size_key == key:
		return
	
#	var iter = 0
	while max_radius > min_radius + 0.5:
#		iter += 1
		var new_radius = (max_radius + min_radius) / 2
		
		var angle_required = 0
		for child in children:
			angle_required += _get_max_angle_for_diagonal(_get_child_min_size(child).length(), new_radius)
			
		if angle_required < 2 * PI:
			max_radius = new_radius # The angle needed is not high enough, we continue trying smaller values
		else:
			min_radius = new_radius # The angle needed is too high, we continue trying larger values
	
#	print(max_radius, "; found in ", iter, " iterations")
	
	_cached_min_size = Vector2(max_radius, max_radius) * 2 + min_child_size
	_cached_min_size_key = key
	
	emit_signal("minimum_size_changed")

func _default_animator(node, container_center, target_pos, time):
	if node is Control:
		node.set_position(container_center.linear_interpolate(target_pos - node.get_size() / 2 * time, time))
	else:
		node.set_position(container_center.linear_interpolate(target_pos, time))
	#node.set_opacity(time)
	if time == 0:
		node.set_scale(Vector2(0.01,0.01))
	else:
		node.set_scale(Vector2(time,time))

## Helpers ##

func _get_filtered_children():
	var children = get_children()
	var i = children.size()
	while i > 0:
		i -= 1
		var keep = false
		if children[i] is Control:
			keep = true
		elif _allow_node2d and children[i] is Node2D:
			keep = true
		
		if children[i] is CanvasItem and children[i].visible==false:
			keep = false
		
		if !keep:
			children.remove(i)
	return children

func _get_child_min_size(child):
	if child is Control:
		var size = child.get_combined_minimum_size()
		if _force_squares:
			var s = max(size.x, size.y)
			return Vector2(s,s)
		return size
	else:
		return Vector2(0,0)

func _get_child_stretch_ratio(child):
	if child is Control and (child.get_h_size_flags() & SIZE_EXPAND or child.get_h_size_flags() & SIZE_EXPAND):
		return child.get_stretch_ratio()
	elif child is Node2D:
		return 1
	elif _force_expand:
		return 1
	else:
		return 0

func _get_max_angle_for_diagonal(diagonal, radius):
	var fit_length = diagonal / 2
	if fit_length > radius:
		return PI
	else:
		return asin(fit_length / radius) * 2

func _private_set(value = null):
	print("Invalid access to private variable!")
	return value

func _private_get(value = null):
	print("Invalid access to private variable!")
	return value
