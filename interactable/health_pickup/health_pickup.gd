extends StaticBody3D


signal animation_ended


func _process(_delta):
	$Pivot/HealthPickupModel/Outline.visible = $Interactable.is_interacting()


func move(location, time):
	var tween = get_tree().create_tween()
	var deep_inside = (location - global_position).normalized()
	tween.tween_property($Pivot, "global_position", location + deep_inside * 0.25, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	animation_ended.emit()
	

func use(player):
	player.health = player.max_health
