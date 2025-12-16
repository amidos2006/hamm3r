extends Node3D


@export var start_actions:JSON


signal cryopod_exit


func _ready():
	Blackout.start()
	await ActionManager.run_actions(start_actions.data, self, $Player)


func _on_cryopod_exit_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		cryopod_exit.emit()
