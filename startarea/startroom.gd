extends Node3D


@export var start_actions:JSON


func _ready():
	Blackout.start()
	await _execute_actions(start_actions.data)
	

func _execute_actions(actions):
	for act in actions:
		match(act.action):
			"open":
				Blackout.open(act.args.start, act.args.end, act.args.time)
				if act.wait:
					await Blackout.animation_ended
			"blur":
				pass
				#$SubViewport.blur_effect(act.args.start, act.args.end, act.args.time)
				#$BlurLayer.blur_effect(act.args.start, act.args.end, act.args.time)
			"timer":
				await get_tree().create_timer(act.args.time).timeout

			"controls":
				$Player.disable_controls = not act.args.enable
