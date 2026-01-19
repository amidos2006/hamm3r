extends StaticBody3D


enum ToiletState{
	OPEN = 0,
	CLOSE = 1
}


var _state = ToiletState.CLOSE


signal animation_ended


func toggle_object():
	if _state == ToiletState.OPEN:
		$Sounds/Close.play()
		$AnimationPlayer.play("close")
	elif _state == ToiletState.CLOSE:
		$Sounds/Open.play()
		$AnimationPlayer.play("open")
	await $AnimationPlayer.animation_finished
	_state = (1 - _state) as ToiletState
	animation_ended.emit()
