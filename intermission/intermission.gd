extends CanvasLayer


var _ui_message
var _ui_action
var _return_scene
var _return_args
var _return_time


func _ready():
	Blackout.start()
	var tween = get_tree().create_tween()
	tween.tween_property($Label, "modulate", Color(Color.WHITE, 1), 2)
	await tween.finished
	if _return_time > 0:
		await get_tree().create_timer(_return_time).timeout
	if _ui_action.length() > 0:
		UiMessage.show_message(_ui_message, _ui_action)
		await UiMessage.advance_message
		UiMessage.hide_message()
	tween = get_tree().create_tween()
	tween.tween_property($Label, "modulate", Color(Color.WHITE, 0), 2)
	await tween.finished
	if _return_scene.length() > 0:
		SceneManager.switch_scene(_return_scene, _return_args)


func initialize(args):
	$Label.text = args.message
	
	_ui_message = ""
	_ui_action = ""
	if "ui_message" in args:
		_ui_message = args.ui_message
		_ui_action = args.ui_action
	
	_return_scene = args.return
	_return_time = 0
	if "time" in args:
		_return_time = args.time
	_return_args = null
	if "args" in args:
		_return_args = args.args
