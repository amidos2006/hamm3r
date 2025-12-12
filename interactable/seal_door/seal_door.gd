extends StaticBody3D


var door_lock = "red"
var first_time = true


enum DoorState{
	OPEN,
	CLOSE,
	FAIL
}

var _state = DoorState.CLOSE
var _active_sound = null


func _ready():
	_active_sound = $Sounds.get_children().pick_random()


func open_door():
	if _state == DoorState.CLOSE:
		$AnimationPlayer.play("open")
		_active_sound.play()
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


func _on_interactable_player_exited() -> void:
	close_door()
