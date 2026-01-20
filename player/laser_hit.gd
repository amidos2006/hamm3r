extends Node3D


func _ready():
	$Hole/Sprite3D_1.rotation_degrees = Vector3(0, 0, randi_range(0, 360))
	$AnimationPlayer.play("Disappear")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Disappear":
		queue_free()
