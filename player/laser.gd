extends Node3D


func fire(length):
	self.visible = true
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(0, 0, length), 0.1)
	tween.tween_property(self, "scale", Vector3(0, 0, length), 0.1)
	await tween.finished
	self.visible = false
	self.scale = Vector3.ONE
