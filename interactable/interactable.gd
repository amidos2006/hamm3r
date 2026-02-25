extends Area3D


@export var interaction:JSON = null
@export var interactable_verb:String = "INTERACT"
@export var disable_interaction:bool = false

var _player = null
var _different_marker = null


signal player_entered
signal player_exited


func is_interacting():
	return _player != null and _player.is_looking_at(get_parent()) and not disable_interaction


func _process(_delta):
	if _player != null:
		if _player.is_looking_at(get_parent()) and not disable_interaction:
			var marker = $FocusPoint
			if _different_marker != null:
				marker = _different_marker
			_player.focus_interactable(get_parent(), marker.global_position, self.interactable_verb)
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


func change_script(path):
	self.interaction = load(path)


func disable_interactable(player, value):
	self.disable_interaction = value
	if self.disable_interaction:
		player.reset_interactable(get_parent())


func interact(player):
	if disable_interaction:
		return
	ActionManager.run_actions(interaction.data, get_parent(), player)
