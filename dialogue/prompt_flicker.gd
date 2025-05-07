extends Label

func _ready():
	while true:
		show()
		await get_tree().create_timer(1).timeout
		hide()
		await get_tree().create_timer(1).timeout
