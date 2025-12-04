extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(-1)


func _deffered_switch_scene(path, args):
	current_scene.free()
	var new_scene = load(path)

	# Instance the new scene.
	current_scene = new_scene.instantiate()
	if "initialize" in current_scene:
		current_scene.initialize(args)
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene


func switch_scene(path, args):
	_deffered_switch_scene.call_deferred(path, args)
