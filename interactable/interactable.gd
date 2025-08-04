extends Area3D


signal player_inside
signal player_exit


func _on_body_entered(body):
	if body.name == "Player":
		player_inside.emit(body, $FocusPoint.position)


func _on_body_exited(body):
	if body.name == "Player":
		player_exit.emit(body)
