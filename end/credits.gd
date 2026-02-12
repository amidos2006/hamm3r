extends CanvasLayer


var tween


signal animation_ended


func _ready():
	$Pivot.position = Vector2(0, get_viewport().get_visible_rect().size.y + 100)


func roll_credits(time):
	var target =  Vector2(0, -$Pivot.size.y - 100)
	if self.tween != null:
		self.tween.stop()
	self.tween = get_tree().create_tween()
	self.tween.tween_property($Pivot, "position", target, time)
	await self.tween.finished
	animation_ended.emit()


func stop_credits():
	if self.tween != null:
		self.tween.stop()


func unroll_credits(time):
	var target =  Vector2(0, get_viewport().get_visible_rect().size.y + 100)
	if self.tween != null:
		self.tween.stop()
	self.tween = get_tree().create_tween()
	self.tween.tween_property($Pivot, "position", target, time)
	await self.tween.finished
	animation_ended.emit()
	

func fade_credits(time):
	var target =  Color(Color.WHITE, 0)
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property($Pivot, "modulate", target, time)
	fade_tween.parallel().tween_property($Logos, "modulate", target, time)
	await fade_tween.finished
	animation_ended.emit()
