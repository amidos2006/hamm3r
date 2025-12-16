extends Node3D


func select_tile(bottom, right, top, left):
	var name = ""
	name += "1" if bottom else "0"
	name += "1" if right else "0"
	name += "1" if top else "0"
	name += "1" if left else "0"
	var active_child = null
	for child in self.get_children():
		if child.name == name:
			active_child = child
			continue
		if child.name.contains("StaticBody"):
			continue
		self.remove_child(child)
	for model in active_child.get_children():
		model.visible = false
	active_child.get_children().pick_random().visible = true
