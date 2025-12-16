extends Node3D


func select_tile(bottom, right, top, left, room_type=""):
	var tile_name = ""
	tile_name += "1" if bottom else "0"
	tile_name += "1" if right else "0"
	tile_name += "1" if top else "0"
	tile_name += "1" if left else "0"
	var active_child = null
	for child in self.get_children():
		if child.name == tile_name:
			active_child = child
			continue
		if not child.name.begins_with("0") and not child.name.begins_with("1"):
			continue
		self.remove_child(child)
	for model in active_child.get_children():
		model.visible = false
	if active_child.has_node(room_type.to_lower()):
		active_child.get_node(room_type.to_lower()).visible = true
	else:
		active_child.get_children().pick_random().visible = true
