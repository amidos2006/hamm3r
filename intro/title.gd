extends CanvasLayer


signal animation_ended


func _ready():
	hide()


func hide_title(time, credits_time):
	var target =  Color(Color.WHITE, 0)
	var tween = get_tree().create_tween()
	tween.tween_property($Name, "modulate", target, time)
	tween.parallel().tween_property($Logos, "modulate", target, time)
	await tween.finished
	target =  Color(Color.WHITE, 1)
	tween = get_tree().create_tween()
	tween.tween_property($Credits, "modulate", target, time)
	await tween.finished
	await get_tree().create_timer(credits_time).timeout
	target =  Color(Color.WHITE, 0)
	tween = get_tree().create_tween()
	tween.tween_property($Credits, "modulate", target, time)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	animation_ended.emit()


func show_title(dx, dy, time):
	show()
	var target_scale = Vector2($Name.scale.x + dx, $Name.scale.y + dy)
	var target_color =  Color(Color.WHITE, 1.0)
	var tween = get_tree().create_tween()
	tween.tween_property($Name, "scale", target_scale, time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Logos, "modulate", target_color, time)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	animation_ended.emit()
