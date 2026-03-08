extends Node3D


@export var flicker_amount:Vector2i = Vector2i(3, 6)


var active_light = true
var flick_light = true


var _model = null


func _process(_delta):
	if self.has_node("OmniLight3D"):
		$OmniLight3D.visible = active_light and flick_light
	_model.visible = active_light


func select_tile(bottom, right, top, left, room_type=""):
	var tile_name = ""
	tile_name += "1" if bottom else "0"
	tile_name += "1" if right else "0"
	tile_name += "1" if top else "0"
	tile_name += "1" if left else "0"
	var is_deadend = tile_name.count("1") == 1
	var is_health_kitchen = is_deadend and room_type == "health"
	var active_child = null
	for child in self.get_children():
		if child.name == tile_name:
			active_child = child
			continue
		if not child.name.begins_with("0") and not child.name.begins_with("1"):
			continue
		self.remove_child(child)
	self._model = active_child
	var variants = []
	for model in active_child.get_children():
		model.visible = false
		if model.name.begins_with("model"):
			variants.append(model)
	
	if active_child.has_node(room_type.to_lower()):
		active_child.get_node(room_type.to_lower()).visible = true
	else:
		variants.pick_random().visible = true
	
	for model in active_child.get_children():
		if not model.visible:
			active_child.remove_child(model)
		elif is_deadend and not is_health_kitchen:
			if model.get_child(0).has_node("HealthPickup"):
				model.get_child(0).get_node("HealthPickup").queue_free()
	
	if room_type.to_lower() == "blocked" or tile_name == "0000":
		$OmniLight3D.queue_free()


func start_light_flickering():
	if self.has_node("OmniLight3D"):
		$Timer.start(0.25)


func _on_timer_timeout() -> void:
	for i in range(randi_range(flicker_amount.x, flicker_amount.y)):
		self.flick_light = !self.flick_light
		await get_tree().create_timer(0.1, false).timeout	
	self.flick_light = true
	$Timer.start(5.0)
