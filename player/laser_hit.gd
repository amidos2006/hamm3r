extends Node3D


func _ready():
	self.hide()
	

func _process(_delta):
	self.visible = $AnimationPlayer.is_playing() or $Sparks_1.is_emitting() or $Sparks_2.is_emitting() or $Sparks_3.is_emitting()


func play():
	self.show()
	$Hole/Sprite3D_1.rotation_degrees = Vector3(0, 0, randi_range(0, 360))
	$AnimationPlayer.play("Disappear")
