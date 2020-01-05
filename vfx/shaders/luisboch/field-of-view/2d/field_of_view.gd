extends Node2D

export var field_of_view = 60
export var radius_warn = 500
export var radius_danger = 200

export var show_circle = false
export var show_fov = true
export var show_target_line = true

export var circle_color = Color("#9f185c0b")

export var fov_color = Color("#b23d7f0b")
export var fov_warn_color = Color("#b1eedf0b")
export var fov_danger_color = Color("#9dfb320b")

export var view_detail = 60

export var enemy_groups = ["Enemy"]

var in_danger_area = []
var in_warn_area = []

# Buffer to target points
var points_arc = []
var is_update = false
func _ready():

	pass

func _process(delta):
	is_update = true
	check_view()
	update()
	pass

func _draw():
	if show_circle:
		draw_circle(get_position(), radius_warn, circle_color)
	
	if show_fov && is_update:
		draw_circle_arc()

func draw_circle_arc():
	for aux in points_arc:
		
		if aux.level == 1 && show_target_line:
				draw_line(get_position(), aux.pos , fov_warn_color)
		elif aux.level == 2 && show_target_line:
			draw_line(get_position(), aux.pos , fov_danger_color, 3)
		else:
				draw_line(get_position(), aux.pos , fov_color)
func deg_to_vector(deg):
	return Vector2( cos(deg2rad(deg)), sin(deg2rad(deg)) )

func check_view():
	var dir_deg = rad2deg(transform.get_rotation())
	var start_angle = dir_deg - (field_of_view * 0.5)
	var end_angle = start_angle + field_of_view
	points_arc = []
	in_danger_area = []
	in_warn_area = []

	var space_state = get_world_2d().direct_space_state

	for i in range(view_detail+1):

		var cur_angle = start_angle + (i *  (float(field_of_view) / float(view_detail))) + 90
		var point = get_position() + deg_to_vector(cur_angle) * radius_warn

		# use global coordinates, not local to node
		var result = space_state.intersect_ray(get_global_transform().origin, to_global(point), [get_parent()])
		
		if result:
			var local_pos = to_local(result.position)
			var dist = get_position().distance_to(local_pos)
			var level = 0
			var is_enemy = false

			if in_danger_area.has(result.collider) || in_warn_area.has(result.collider):
				points_arc.append({"pos": local_pos, "level": level})
				pass
			else:
				for g in enemy_groups :
					if result.collider.get_groups().has(g):
						is_enemy = true
				
				if is_enemy:
					level = 1
					if dist < radius_danger :
						level = 2
						in_danger_area.append(result.collider)
					else :
						in_warn_area.append(result.collider)
					# check if directly to target, we can "shoot"
					var tgt_pos = result.collider.get_global_transform().origin
					var this_pos = get_global_transform().origin
					var tgt_dir = (tgt_pos - this_pos).normalized()
					var view_angle = rad2deg(deg_to_vector(rad2deg(get_global_transform().get_rotation())+90).angle_to(tgt_dir))
	
					if view_angle > start_angle && view_angle < end_angle:
						var result2 = space_state.intersect_ray(this_pos, tgt_pos, [get_parent()])
						if result2 && result2.collider == result.collider :
							# we can, then use this as line
							points_arc.append({"pos": local_pos, "level": 0})
							if show_target_line:
								points_arc.append({"pos": to_local(tgt_pos), "level": level})

						else :
							points_arc.append({"pos": local_pos, "level": level})
					else :	
						points_arc.append({"pos": local_pos, "level": level})
				else :
					points_arc.append({"pos": local_pos, "level": level})

		else :
			points_arc.append({"pos": point, "level": 0})

	#print(points_arc.size())
