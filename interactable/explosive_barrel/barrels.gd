extends Node3D


func _ready():
	var barrels = $Pivot.get_children()
	for b in barrels:
		b.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
		b.position = b.position + Vector3(sign(b.position.x) * randf_range(0, 0.1), 0, randf_range(-0.1, 0.1))
