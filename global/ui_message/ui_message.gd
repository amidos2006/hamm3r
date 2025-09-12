extends CanvasLayer


var _action_name
var _active


signal advance_message


func _ready():
	hide_message()


func _process(_delta):
	if _active and _action_name.length() > 0 and Input.is_action_just_pressed(_action_name):
		hide_message()
		advance_message.emit()


func show_message(message, action_name, time = 1.0):
	$Label.text = message
	_action_name = action_name
	_active = true
	show()
	$Label.show()
	while time > 0 and _active:
		await get_tree().create_timer(time).timeout
		$Label.hide()
		await get_tree().create_timer(time).timeout
		$Label.show()


func hide_message():
	_action_name = ""
	_active = false
	hide()
