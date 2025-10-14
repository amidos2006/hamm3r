extends Area3D


@export var interaction:JSON = null


var _player = null
var _different_marker = null


var disable_interaction = false


signal player_entered
signal player_exited


func _process(delta):
	if _player != null:
		if _player.is_looking_at(get_parent()) and not disable_interaction:
			var marker = $FocusPoint
			if _different_marker != null:
				marker = _different_marker
			_player.focus_interactable(get_parent(), marker.global_position)
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
	if disable_interaction:
		return
	
	print(interaction.data.size())
	for act in interaction.data:
		print(act.action)
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
				self.disable_interaction = not act.args.enable
				if self.disable_interaction:
					player.reset_interactable(get_parent())
			"function":
				if act.args.player:
					player.call(act.args.name, get_parent())
					if act.wait and act.args.signal.length() > 0:
						await Signal(player, act.args.signal)
				else:
					get_parent().call(act.args.name)
					if act.wait and act.args.signal.length() > 0:
						await Signal(get_parent(), act.args.signal)
			"script":
				if act.args.name == "change":
					var object = get_parent()
					if act.args.has("other"):
						object = object.get_parent().get_node(act.args.other)
					object.get_node("Interactable").interaction = load(act.args.path)
			"look":
				if act.args.enable:
					_different_marker = get_parent().get_node(act.args.name)
					player.focus_interactable(null, _different_marker.global_position)
				else:
					_different_marker = null
			"rotate":
				player.rotate_focus(get_parent())
				_different_marker = null
