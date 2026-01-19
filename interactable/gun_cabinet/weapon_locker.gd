extends StaticBody3D


enum DoorState{
	OPEN,
	CLOSE
}


@export var contain_gun = false
@export var empty_json:JSON = null
@export var gun_json:JSON = null


signal animation_ended


var _state = DoorState.CLOSE


func _ready():
	if not contain_gun:
		$Interactable.interaction = empty_json
		$Gun.queue_free()
	else:
		$Interactable.interaction = gun_json


func open_door():
	if _state == DoorState.CLOSE:
		if contain_gun:
			$Gun.start_effect()
		$AnimationPlayer.play("Open")
		$Sounds/Open.play()
		await $AnimationPlayer.animation_finished
		_state = DoorState.OPEN
	animation_ended.emit()
	
	
func close_door():
	if _state == DoorState.OPEN:
		_state = DoorState.CLOSE
		$AnimationPlayer.play("Close")
		$Sounds/Close.play()
		await $AnimationPlayer.animation_finished
		if contain_gun:
			$Gun.stop_effect()
	animation_ended.emit()
		

func toggle_object():
	if _state == DoorState.OPEN:
		close_door()
	elif _state == DoorState.CLOSE:
		open_door()
		

func remove_gun():
	if contain_gun:
		contain_gun = false
		$Gun.queue_free()
