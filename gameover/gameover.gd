extends CanvasLayer


var _return_scene


func _ready():
	$Blackout.start()
	var tween = get_tree().create_tween()
	tween.tween_property($Label, "modulate", Color(Color.WHITE, 1), 2)
	await tween.finished
	$UIMessage.show_message("PRESS [color=#d1ff85][font_size=72]SPACE[/font_size][/color] TO RESTART", "interact")
	await $UIMessage.advance_message
	$UIMessage.hide_message()
	tween = get_tree().create_tween()
	tween.tween_property($Label, "modulate", Color(Color.WHITE, 0), 2)
	await tween.finished
	Global.switch_scene(_return_scene, null)


func initialize(args):
	_return_scene = args.return
