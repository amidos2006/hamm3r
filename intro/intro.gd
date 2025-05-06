extends Node


@export var start_actions:JSON
@export var soft_actions:JSON
@export var medium_actions:JSON
@export var hard_actions:JSON
@export var leave_actions:JSON
@export var end_actions:JSON


var _docking_speed
var _soft_threshold
var _medium_threshold


func _ready():
	_docking_speed = 0
	await _execute_actions(start_actions.data)
	$Dialogue.hide_message()
	$UIMessage.hide_message()
	if _docking_speed < 0:
		await _execute_actions(leave_actions.data)
	elif _docking_speed < _soft_threshold:
		await _execute_actions(soft_actions.data)
		await _execute_actions(end_actions.data)
	elif _docking_speed < _medium_threshold:
		await _execute_actions(medium_actions.data)
		await _execute_actions(end_actions.data)
	else:
		await _execute_actions(hard_actions.data)
		await _execute_actions(end_actions.data)


func _execute_actions(actions):
	for act in actions:
		match(act.action):
			"show_message":
				$UIMessage.show_message(act.args.message, act.args.action, act.args.time)
				if act.wait:
					await $UIMessage.advance_message
			"show_dialogue":
				$Dialogue.show_message(act.args.name, act.args.mood, act.args.text, act.args.time, act.args.action)
				if act.wait:
					await $Dialogue.advance_dialogue
			"move_camera":
				$Camera2D.move_camera(act.args.dx, act.args.dy, act.args.time)
				if act.wait:
					await $Camera2D.animation_ended
			"start_minigame":
				$Ship.start_moving(act.args.start_speed, act.args.attraction_force, act.args.thruster_force, act.args.thruster_acc, act.args.thruster_dec, act.args.action, $Station.position)
				_soft_threshold = act.args.soft_speed
				_medium_threshold = act.args.medium_speed
				if act.wait:
					_docking_speed = await $Ship.ship_docked
			"ship_exit":
				$Ship.ship_exit(act.args.attraction_force, act.args.thruster_force, act.args.thruster_acc, act.args.thruster_dec, act.args.time)
				if act.wait:
					await $Ship.ship_docked
			"shake_camera":
				$Camera2D.shake_camera(act.args.strength, act.args.frames)
				if act.wait:
					await $Camera2D.animation_ended
			"zoom_camera":
				$Camera2D.zoom_camera(act.args.dx, act.args.dy, act.args.time)
				if act.wait:
					await $Camera2D.animation_ended
			"play_sound":
				pass
			"show_title":
				$Title.show_title(act.args.dx, act.args.dy, act.args.time)
				if act.wait:
					await $Title.animation_ended
			"hide_title":
				$Title.hide_title(act.args.time)
				if act.wait:
					await $Title.animation_ended
			"fade":
				$Blackout.fade(act.args.start, act.args.end, act.args.time)
				if act.wait:
					await $Blackout.animation_ended
