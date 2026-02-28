extends Node3D


var _laser_hits = []


func _ready():
	for i in range(1, 6):
		_laser_hits.append(get_node("../LaserHits/LaserHit_" + str(i)))
		_laser_hits[-1].top_level = true


func _get_laser_hit():
	for lh in _laser_hits:
		if not lh.visible:
			return lh
	return null
		


func fire(hit_pos, norm, length):
	self.visible = true
	self.scale = Vector3(1, 1, length)
	var hit = self._get_laser_hit()
	hit.play()
	hit.look_at_from_position(hit_pos, hit_pos + norm)
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(0, 0, length), 0.1)
	tween.tween_property(self, "scale", Vector3(0, 0, length), 0.1)
	await tween.finished
	self.visible = false
	self.scale = Vector3.ONE
