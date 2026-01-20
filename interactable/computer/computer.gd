extends StaticBody3D


func _ready():
	$AnimationPlayer.play("Idle")


func show_ship():
	pass


func show_gun():
	$AnimationPlayer.play("Gun_Show")
