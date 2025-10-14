extends Area3D


signal animation_ended


func _ready():
	$Effect.visible = false
	$Effect/AnimationPlayer.stop()


func start_effect():
	$Effect.visible = true
	$Effect/AnimationPlayer.play("idle")
	
	
func stop_effect():
	$Effect.visible = false
	$Effect/AnimationPlayer.stop()
	
	
func move_gun(location, time):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector3(), time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	animation_ended.emit()
	
