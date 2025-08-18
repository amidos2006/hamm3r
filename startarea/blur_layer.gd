extends CanvasLayer

func _set_shader_power(value):
	$ColorRect.material.set_shader_parameter("power", value)


func blur_effect(start, end, time):
	var tween = get_tree().create_tween()
	_set_shader_power(start)
	tween.tween_method(Callable(self, "_set_shader_power"), start, end, time)
	await tween.finished
