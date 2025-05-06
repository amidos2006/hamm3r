extends Camera2D


signal animation_ended


func follow_camera(ship, station):
	pass


func move_camera(dx, dy, time):
	var target = Vector2(position.x + dx, position.y + dy)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target, time).set_trans(Tween.TRANS_SINE)
	await tween.finished
	animation_ended.emit()


func zoom_camera(dx, dy, time):
	var target = Vector2(zoom.x + dx, zoom.y + dy)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", target, time).set_trans(Tween.TRANS_SINE)
	await tween.finished
	animation_ended.emit()


func shake_camera(strength, frames):
	for i in frames:
		offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		await get_tree().create_timer(0.01).timeout
	offset = Vector2.ZERO
	animation_ended.emit()
	
