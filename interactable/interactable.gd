extends Area3D


@export var interaction:JSON = null


var _player = null
var _disable_interaction = false


signal player_entered
signal player_exited


func _process(delta):
	if _player != null:
		if _player.is_looking_at(get_parent()):
			_player.focus_interactable(get_parent(), $FocusPoint.global_position)
		else:
			_player.reset_interactable(get_parent())


func _on_body_entered(body):
	if body.name == "Player":
		_player = body
		player_entered.emit()


func _on_body_exited(body):
	if body.name == "Player":
		_player = null
		body.reset_interactable(get_parent())
		player_exited.emit()


func interact(player):
	if _disable_interaction:
		return
	
	for act in interaction.data:
		match(act.action):
			"controls":
				player.disable_controls = not act.args.enable
			"show_message":
				UiMessage.show_message(act.args.message, act.args.action, act.args.time)
				if act.wait:
					await UiMessage.advance_message
			"show_dialogue":
				Dialogue.show_message(act.args.name, act.args.mood, act.args.text, act.args.direction, act.args.time, act.args.action)
				if act.wait:
					await Dialogue.advance_dialogue
			"timer":
				await get_tree().create_timer(act.args.time).timeout
			"interaction":
				self._disable_interaction = not act.args.enable
			"function":
				if act.args.player:
					player.call(act.args.name, get_parent())
					if act.wait and act.args.signal.length() > 0:
						await player.to_signal(player, act.args.signal)
				else:
					get_parent().call(act.args.name)
					if act.wait and act.args.signal.length() > 0:
						await get_parent().to_signal(get_parent(), act.args.signal)
				
