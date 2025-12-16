extends StaticBody3D


enum ToiletState{
	OPEN = 0,
	CLOSE = 1
}


var _state = ToiletState.CLOSE


signal animation_ended


func toggle_object():
	if _state == ToiletState.OPEN:
		$AnimationPlayer.play("close")
	elif _state == ToiletState.CLOSE:
		$AnimationPlayer.play("open")
	await $AnimationPlayer.animation_finished
	_state = 1 - _state
	animation_ended.emit()
