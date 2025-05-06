extends CanvasLayer


signal animation_ended


func start(color="#000000"):
	$ColorRect.color = Color(color)


func fade(start_alpha, end_alpha, time, color="#000000"):
	var start_value = Color(color, start_alpha)
	var target_value = Color(color, end_alpha)
	$ColorRect.color = start_value
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", target_value, time)
	await tween.finished
	animation_ended.emit()
