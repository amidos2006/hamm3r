extends Node3D


func select_tile(bottom, right, top, left):
	var name = ""
	name += "1" if bottom else "0"
	name += "1" if right else "0"
	name += "1" if top else "0"
	name += "1" if left else "0"
	for child in self.get_children():
		if child.name == name:
			continue
		self.remove_child(child)
