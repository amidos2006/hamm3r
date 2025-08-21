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
		await _apply_event(body)
		event_finished.emit()
		if singleton:
			disable_event = true
			queue_free()


func _on_body_exited(body):
	if body.name == "Player" and not disable_event:
		player_exited.emit()


func _apply_event(player):
	for act in event.data:
		match(act.action):
			"controls":
				player.disable_controls = not act.args.enable
				for key in act.args:
					if key in player.allowed_controls:
						player.allowed_controls[key] = act.args[key]
				if "angle" in act.args:
					player.restricted_angle = Vector2(act.args.angle.min, act.args.angle.max)
			"show_dialogue":
				Dialogue.show_message(act.args.name, act.args.mood, act.args.text, act.args.direction, act.args.time, act.args.action)
				if act.wait:
					await Dialogue.advance_dialogue
			"timer":
				await get_tree().create_timer(act.args.time).timeout
			"interaction":
				self.disable_event = not act.args.enable
			
			"function":
				var target = player
				if "target" in act.args:
					target = get_node(act.args.target)
				target.call(act.args.name)
				if act.wait and act.args.signal.length() > 0:
					await Signal(target, act.args.signal)
					
			"look":
				if act.args.enable:
					player.focus_interactable(null, get_node(act.args.name).global_position)
				else:
					player.reset_interactable(null)
				
