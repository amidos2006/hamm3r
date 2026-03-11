extends MeshInstance3D


func explode(pos, time):
	self.top_level = true
	self.global_position = pos
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(5, 5, 5), time)
