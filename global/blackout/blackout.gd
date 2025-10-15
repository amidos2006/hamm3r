extends CanvasLayer


signal animation_ended


func start(color="#000000"):
	$ColorRect.color = Color(color)
	$ColorRect_1.color = Color(color)
	$ColorRect_2.color = Color(color)
	$FreezeTexture.visible = false


func fade(start_alpha, end_alpha, time, color="#000000"):
	$ColorRect.visible = true
	$ColorRect_1.visible = false
	$ColorRect_2.visible = false
	$FreezeTexture.visible = false
	
	var start_value = Color(color, start_alpha)
	var target_value = Color(color, end_alpha)
	$ColorRect.color = start_value
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", target_value, time)
	await tween.finished
	animation_ended.emit()


func open(start_open, end_open, time):
	$ColorRect.visible = false
	$ColorRect_1.visible = true
	$ColorRect_2.visible = true
	$FreezeTexture.visible = true
	
	var start_value = Vector2(0, $ColorRect.size.y * (1.0 + start_open) / 2)
	var end_value = Vector2(0, $ColorRect.size.y * (1.0 + end_open) / 2)
	$ColorRect_1.position = -start_value
	$ColorRect_2.position = start_value
	var start_color = Color("b5e1ffff")
	var end_color = Color("b5e1ff00")
	$FreezeTexture.modulate = start_color
	var tween = get_tree().create_tween()
	tween.tween_property($FreezeTexture, "modulate", end_color, 2*time)
	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($ColorRect_1, "position", -end_value, time).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	tween.tween_property($ColorRect_2, "position", end_value, time).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	await tween.finished
	animation_ended.emit()
