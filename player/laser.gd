extends Node3D


var _laser_hit = preload("res://player/laser_hit.tscn")


func fire(collider, hit_pos, norm, length):
	self.visible = true
	self.scale = Vector3(1, 1, length)
	var hit = null
	if collider != null:
		hit = _laser_hit.instantiate()
		collider.get_parent().add_child(hit)
		hit.look_at_from_position(hit_pos, hit_pos + norm)
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(0, 0, length), 0.1)
	tween.tween_property(self, "scale", Vector3(0, 0, length), 0.1)
	await tween.finished
	self.visible = false
	self.scale = Vector3.ONE
