extends StaticBody3D


@export var start_open = false
@export var can_open = true


func _ready():
	var start_animation = "open"
	if start_open:
		if can_open:
			start_animation = "open"
			$CollisionShape3D.set_deferred("disabled", true)
		else:
			start_animation = "fail"
			$CollisionShape3D.set_deferred("disabled", false)
	$AnimationPlayer.play(start_animation)
	$AnimationPlayer.seek($AnimationPlayer.current_animation_length, false)


func open_door():
	if $CollisionShape3D.disabled:
		if can_open:
			$AnimationPlayer.play("open")
			await $AnimationPlayer.animation_finished
			$CollisionShape3D.set_deferred("disabled", false)
		else:
			$AnimationPlayer.play("fail")
	
func close_door():
	if not $CollisionShape3D.disabled:
		$CollisionShape3D.set_deferred("disabled", true)
		$AnimationPlayer.play("close")
	
