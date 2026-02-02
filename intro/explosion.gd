extends Node2D

var _speed = 0

func explode():
	$AnimationPlayer.play("Explode")
	$Cargo.visible = true
	$Base.visible = true
	_speed = 30


func _process(delta):
	$Cargo.position += Vector2(randf_range(-1,1), -3).normalized() * _speed * delta
	$Base.position += Vector2(randf_range(-1,1), 3).normalized() * _speed * delta
