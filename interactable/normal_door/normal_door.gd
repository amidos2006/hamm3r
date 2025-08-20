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
		$Interactable.disable_interaction = true


func fail_door():
	if _state == DoorState.CLOSE:
		$AnimationPlayer.play("fail")
		_state = DoorState.FAIL
		await $AnimationPlayer.animation_finished
		$Interactable.disable_interaction = true


func close_door():
	if _state == DoorState.OPEN:
		$CollisionShape3D.set_deferred("disabled", false)
		$AnimationPlayer.play("close")
		await $AnimationPlayer.animation_finished
		_state = DoorState.CLOSE
		$Interactable.disable_interaction = false


func _on_interactable_player_exited():
	close_door()
