extends StaticBody3D

enum DoorState{
	OPEN,
	CLOSE
}


@export var show_note = true


signal animation_ended


var _state = DoorState.CLOSE


func _ready():
	if not show_note:
		$Pivot/Base/Note.hide()
	else:
		$CollisionShape3D.disabled = true


func open_door():
	if _state == DoorState.CLOSE:
		$AnimationPlayer.play("open")
		await $AnimationPlayer.animation_finished
		animation_ended.emit()
		

func disable_interaction():
	$Interactable.disable_interaction = true
	
	
func enable_interaction():
	$Interactable.disable_interaction = false
