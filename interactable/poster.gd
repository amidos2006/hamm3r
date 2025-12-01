extends StaticBody3D


func _ready():
	for child in $Pivot.get_children():
		child.hide()
	$Pivot.get_children().pick_random().show()
