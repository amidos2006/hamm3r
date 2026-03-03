extends Control

var velocity

func _ready():
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property($AnimationSprite, "scale", Vector2(0.95 *  $AnimationSprite.scale.x ,  $AnimationSprite.scale.y), 0.1)
	tween.tween_property($AnimationSprite, "scale", $AnimationSprite.scale, 0.1)
	tween = get_tree().create_tween().set_loops()
	tween.tween_property($AnimationSprite, "modulate", Color(Color.WHITE, 0.9), 0.1)
	tween.tween_property($AnimationSprite, "modulate", Color(Color.WHITE, 1), 0.1)
	velocity = Vector2.from_angle(1.05 * PI) * 40


func _process(delta):
	if not self.visible:
		return
	$AnimationSprite.play("high")
	if not $Sounds/Engine.playing:
		$Sounds/Engine.play()
	self.position += self.velocity * delta
