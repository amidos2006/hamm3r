extends Area3D


@export var event:JSON = null
@export var disable_event = false
@export var singleton = true


signal player_entered
signal player_exited
signal event_finished


func _on_body_entered(body):
	if body.name == "Player" and not disable_event:
		player_entered.emit()
		await ActionManager.run_actions(event.data, self, body)
		event_finished.emit()
		if singleton:
			disable_event = true
			queue_free()


func _on_body_exited(body):
	if body.name == "Player" and not disable_event:
		player_exited.emit()
