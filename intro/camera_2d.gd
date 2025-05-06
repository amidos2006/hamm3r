extends Camera2D


signal animation_ended


var _following = false


func follow_camera(move_speed, zoom_speed, ship, station):
	var direction = station.global_position - ship.global_position
	direction = direction.normalized()
	
	var last_distance = (ship.global_position - station.global_position).length()
	_following = true
	while _following:
		var new_distance = (ship.global_position - station.global_position).length()
		if new_distance < last_distance:
			var factor = (last_distance - new_distance) / last_distance
			position += direction * factor * move_speed
			zoom += Vector2.ONE * factor * zoom_speed
			last_distance = new_distance
		await get_tree().create_timer(0.01).timeout
	animation_ended.emit()


func stop_follow():
	_following = false


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
	
