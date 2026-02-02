extends Node


@export var start_actions:JSON
@export var soft_actions:JSON
@export var medium_actions:JSON
@export var hard_actions:JSON
@export var explosion_actions:JSON
@export var leave_actions:JSON
@export var end_actions:JSON


var _docking_speed
var _soft_threshold
var _medium_threshold
var _high_threshold


func _ready():
	Blackout.start()
	_docking_speed = 0
	await ActionManager.run_actions(start_actions.data, self)
	Dialogue.hide_message()
	UiMessage.hide_message()
	print(_docking_speed)
	if _docking_speed < 0:
		await await ActionManager.run_actions(leave_actions.data, self)
	elif _docking_speed < _soft_threshold:
		$Ship/Sounds/Light.play(0.1)
		await ActionManager.run_actions(soft_actions.data, self)
		await ActionManager.run_actions(end_actions.data, self)
	elif _docking_speed < _medium_threshold:
		$Ship/Sounds/Medium.play(0.1)
		await ActionManager.run_actions(medium_actions.data, self)
		await ActionManager.run_actions(end_actions.data, self)
	elif _docking_speed < _high_threshold:
		$Ship/Sounds/Hard.play(0.1)
		await ActionManager.run_actions(hard_actions.data, self)
		await ActionManager.run_actions(end_actions.data, self)
	else:
		await ActionManager.run_actions(explosion_actions.data, self)
