extends Line2D

class Segment:
	var start
	var end
	func _init(start,end):
		self.start = start
		self.end = end
	func mid():
		return (self.start+self.end) / 2

var min_width = 1

func apply_lightning(end_point, num_generations, max_offset, split_end_likelihood = 0.3, split_end_likelihood_decay = 0.75, split_end_scale_decay = 0.6, split_end_rot_range = 0.5):
	var segments = []
	segments.push_back(Segment.new(Vector2(0,0), end_point))
	
	var offset = max_offset;
	for gen_no in range(num_generations):
		var new_segs = []
		for i in range(len(segments)):
			var seg = segments.pop_front()
			var direction = seg.start - seg.end
			var mid = seg.mid()
			
			mid += (direction.normalized() * rand_range(-offset,offset)).tangent()
			new_segs.append(Segment.new(seg.start, mid));
			new_segs.append(Segment.new(mid, seg.end));
		segments = new_segs
		offset /= 2; # Reduce offset each generation (fractal pattern)
	
	#create new segments afterwards so the positions are stable
	for segment in segments:
		if randf() < split_end_likelihood:
			var split_end2 = preload("./Lightning.tscn").instance()
			add_child(split_end2)
			var new_color = self.default_color
#			new_color.a *= alpha_fade_per_split
			split_end2.width = max(self.width * 0.5, min_width)
			split_end2.default_color = new_color
			split_end2.position = segment.mid()
			split_end2.rotation_degrees = (segment.end - segment.start).angle() + (rand_range(-split_end_rot_range, split_end_rot_range))
			var split_ends_end = end_point.length() * split_end_scale_decay * Vector2(1,0).rotated(split_end2.rotation_degrees)
			split_end2.apply_lightning(split_ends_end, num_generations-1, offset, split_end_likelihood *split_end_likelihood_decay, split_end_scale_decay, split_end_rot_range)
	
	#remove old points
	while self.points.size() > 0:
		self.remove_point(0)
	
	#add new points
	for seg in segments:
		self.add_point(seg.start)
	self.add_point(segments[len(segments)-1].end)
