extends MeshInstance3D


func change_color():
	var material = get_surface_override_material(0)
	material.emission = Color("#77de5b")
