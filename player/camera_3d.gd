extends Camera3D


func shake_camera(time, strength=0.05):
	var total_time = 0
	while total_time < time:
		self.position = Vector3(randf_range(-strength, strength), randf_range(-strength, strength), 0)
		await get_tree().create_timer(0.05, false).timeout
		total_time += 0.05
