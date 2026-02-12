extends Node


@export var end_actions:JSON


func _ready():
	$Camera2D.enabled = false
	$Camera2D.enabled = true
	ActionManager.run_actions(end_actions.data, self, null)
