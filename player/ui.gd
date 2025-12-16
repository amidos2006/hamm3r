extends CanvasLayer


signal animation_ended


var _heart_scene = preload("res://player/heart_ui.tscn")


func _ready():
	$TopPivot.position = Vector2(0, -$TopPivot.size.y / 2)
	$BottomPivot.position = Vector2(0, $BottomPivot.size.y)


func show_ui(time):
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($TopPivot, "position", Vector2(), time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property($BottomPivot, "position", Vector2(), time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
	animation_ended.emit()


func initialize_health(health, max_health):
	for index in max_health:
		var heart = _heart_scene.instantiate()
		$TopPivot/HeartContainer.add_child(heart)
		heart.set_health(index < health)


func update_health(health):
	var children = $Pivot/HeartContainer.get_children()
	for index in children.size():
		children[index].set_health(index < health)
