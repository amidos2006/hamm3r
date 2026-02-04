extends Node


var current_scene = null
var _upcoming_scene = null
var _upcoming_args = null
var _upcoming_done = null
var _upcoming_called = false


func _ready():
	var root = get_tree().root
	current_scene = root.get_child(-1)


func _process(_delta):
	if self._upcoming_scene != null:
		if ResourceLoader.load_threaded_get_status(_upcoming_scene) == ResourceLoader.THREAD_LOAD_LOADED and not self._upcoming_called:
			self._upcoming_called = true
			if self._upcoming_done != null:
				self._upcoming_done.call()
			else:
				self.execute_scene()


func _deffered_switch_scene(path, args, done_fn):
	self._upcoming_scene = path
	self._upcoming_args = args
	self._upcoming_done = done_fn
	self._upcoming_called = false
	ResourceLoader.load_threaded_request(_upcoming_scene)


func execute_scene():
	_load_scene(ResourceLoader.load_threaded_get(self._upcoming_scene), self._upcoming_args)


func _load_scene(new_scene, args):
	self._upcoming_scene = null
	self._upcoming_args = null
	self._upcoming_done = null
	self.current_scene.free()

	# Instance the new scene.
	self.current_scene = new_scene.instantiate()
	if "initialize" in current_scene:
		self.current_scene.initialize(args)
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene


func switch_scene(path, args, done_fn=null):
	self._deffered_switch_scene.call_deferred(path, args, done_fn)
