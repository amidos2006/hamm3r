extends Node3D


@export var start_actions:JSON


signal cryopod_exit


func _ready():
	Blackout.start()
	await _execute_actions(start_actions.data)
	

func _execute_actions(actions):
	for act in actions:
		match(act.action):
			"show_message":
				UiMessage.show_message(act.args.message, act.args.action, act.args.time)
				if act.wait:
					await UiMessage.advance_message
			"show_dialogue":
				Dialogue.show_message(act.args.name, act.args.mood, act.args.text, act.args.direction, act.args.time, act.args.action)
				if act.wait:
					await Dialogue.advance_dialogue
					
			"open":
				Blackout.open(act.args.start, act.args.end, act.args.time)
				if act.wait:
					await Blackout.animation_ended
			"blur":
				pass
				#$SubViewport.blur_effect(act.args.start, act.args.end, act.args.time)
				#$BlurLayer.blur_effect(act.args.start, act.args.end, act.args.time)
			
			"signal":
				var target = get_node(act.args.target)
				if act.wait:
					await Signal(target, act.args.name)
					UiMessage.hide_message()
			"function":
				var obj = get_node(act.args.target)
				obj.call(act.args.name)
				if act.wait and act.args.signal.length() > 0:
					await Signal(obj, act.args.signal)
			"timer":
				await get_tree().create_timer(act.args.time).timeout

			"controls":
				$Player.disable_controls = not act.args.enable
				for key in act.args:
					if key in $Player.allowed_controls:
						$Player.allowed_controls[key] = act.args[key]
				if "angle" in act.args:
					$Player.restricted_angle = Vector2(act.args.angle.min, act.args.angle.max)
			
			"sound":
				if act.args.name.to_lower() == "fade":
					var target = get_node(act.args.target)
					var tween = get_tree().create_tween()
					tween.tween_property(target, "volume_db", act.args.value, act.args.time)


func _on_cryopod_exit_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		cryopod_exit.emit()
