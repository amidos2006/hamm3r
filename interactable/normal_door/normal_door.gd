extends StaticBody3D


enum DoorState{
	OPEN,
	CLOSE,
	FAIL
}


var _state = DoorState.CLOSE


func open_door():
	if _state == DoorState.CLOSE:
		$AnimationPlayer.play("open")
		await $AnimationPlayer.animation_finished
		$CollisionShape3D.set_deferred("disabled", true)
		_state = DoorState.OPEN


func fail_door():
	if _state == DoorState.CLOSE:
		$AnimationPlayer.play("fail")
		_state = DoorState.FAIL


func close_door():
	if _state == DoorState.OPEN:
		$CollisionShape3D.set_deferred("disabled", false)
		$AnimationPlayer.play("close")
		_state = DoorState.CLOSE


func _on_interactable_player_exited():
	close_door()
