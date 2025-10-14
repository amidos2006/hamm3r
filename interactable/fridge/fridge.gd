extends StaticBody3D


enum DoorState{
	OPEN,
	CLOSE
}


signal animation_ended


var _state = DoorState.CLOSE


func open_door():
	if _state == DoorState.CLOSE:
		$AnimationPlayer.play("Open")
		await $AnimationPlayer.animation_finished
		_state = DoorState.OPEN
		animation_ended.emit()
	
	
func close_door():
	if _state == DoorState.OPEN:
		_state = DoorState.CLOSE
		$AnimationPlayer.play("Close")
		await $AnimationPlayer.animation_finished
		animation_ended.emit()
