extends CharacterBody3D


@export var movement_speed = 4
@export var backward_ratio = 0.4
@export var rotation_speed = 5
@export var gravity = 4
@export var max_health = 5
@export var health = 3
@export var bark_data:Array[JSON]
@export var bark_time:Vector2 = Vector2(25, 35)

var disable_controls:
	set(value):
		for key in allowed_controls:
			allowed_controls[key] = not value
		if not value:
			restricted_angle = null
var allowed_controls = {
	"left": true,
	"right": true,
	"forward": true,
	"backward": true,
	"interact": true
}
var restricted_angle = null
var gun_equipped = false
var inside_hamm = true
var back_hamm = false
var inside_cryo = true
var bark_timer:bool:
	set(value): $BarkTimer.paused = not value
var bark_index = 0


signal angle_left
signal angle_right
signal animation_ended


var _interactable_object = null
var _interactable_focus = Vector3.ZERO
var _target_velocity = Vector3.ZERO
var _is_shooting = false


func _ready():
	$UI.initialize_health(health, max_health)
	$Pivot/Camera3D/Gun.visible = false
	bark_data.shuffle()


func _get_rotation(target_pos):
	var old_rotation = $Pivot/Camera3D.rotation
	$Pivot/Camera3D.look_at(target_pos, Vector3.UP)
	var new_rotation = $Pivot/Camera3D.rotation
	$Pivot/Camera3D.rotation = old_rotation
	return new_rotation


func _physics_process(delta):
	var movement = 0
	var direction = 0
	if allowed_controls["forward"] and Input.is_action_pressed("forward") and allowed_controls:
		movement -= 1
	elif allowed_controls["backward"] and  Input.is_action_pressed("backward"):
		movement += backward_ratio
		
	if allowed_controls["right"] and Input.is_action_pressed("right"):
		direction -= 1
	elif allowed_controls["left"] and Input.is_action_pressed("left"):
		direction += 1
			
	if allowed_controls["interact"] and Input.is_action_just_pressed("interact"):
		if _interactable_object != null:
			_interactable_object.get_node("Interactable").interact(self)
		elif gun_equipped:
			if inside_hamm:
				Dialogue.show_message("martin", "normal", "#no_shooting#", "left", 3, "")
			elif not self._is_shooting:
				var laser_length = $RayCast3D.target_position.length()
				var laser_position = Vector3.ZERO
				var laser_normal = Vector3.ZERO
				var laser_collider = null
				if $RayCast3D.is_colliding():
					laser_length = self.global_position.distance_to($RayCast3D.get_collision_point())
					laser_position = $RayCast3D.get_collision_point()
					laser_normal = $RayCast3D.get_collision_normal()
					laser_collider = $RayCast3D.get_collider()
					if $RayCast3D.get_collider().is_in_group("Explosive"):
						SceneManager.switch_scene("res://end/end.tscn", {})
				$Pivot/Camera3D/Laser/AudioStreamPlayer3D.play()
				$AnimationPlayer.play("Shoot")
				$AnimationPlayer.speed_scale = 1
				$Pivot/Camera3D/Laser.fire(laser_collider, laser_position, laser_normal, laser_length)
				self._is_shooting = true
	
	if direction != 0:
		rotate_y(direction * rotation_speed * PI / 360)
		var temp_angle = rotation_degrees.y
		if temp_angle < 0:
			temp_angle += 360
		if restricted_angle != null:
			temp_angle = clamp(temp_angle, restricted_angle.x, restricted_angle.y)
			rotation_degrees.y = temp_angle
		if temp_angle > 270:
			angle_left.emit()
		if temp_angle < 90:
			angle_right.emit()
	
	var forward = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	_target_velocity.x = (forward * movement * movement_speed).x
	_target_velocity.z = (forward * movement * movement_speed).z
	_target_velocity.y -= delta * gravity
	if is_on_floor():
		_target_velocity.y = 0
		if (abs(self.velocity.x + self.velocity.z) > 0 or abs(direction) > 0) and not $WalkingSounds/Metal.playing and not inside_cryo:
			$WalkingSounds/Metal.play()
	velocity = _target_velocity
	if gun_equipped and not self._is_shooting:
		if abs(movement) + abs(direction) > 0:
			$AnimationPlayer.play("Walk")
			var anim_dir = sign(movement)
			if abs(direction) > 0:
				anim_dir = -sign(direction)
			$AnimationPlayer.speed_scale = anim_dir
		else:
			$AnimationPlayer.play("Idle")
	if gun_equipped:
		$UI.update_health(health)
		
	move_and_slide()
	
	# we need to make function for rotating and looking
	$Pivot/Camera3D.rotation = lerp($Pivot/Camera3D.rotation, _interactable_focus, 0.1)
	
	
func focus_interactable(interactable, focus_point):
	_interactable_object = interactable
	_interactable_focus = _get_rotation(focus_point)
	if _interactable_object and not _interactable_object.get_node("Interactable").disable_interaction:
		UiMessage.show_message("PRESS [color=#d1ff85][font_size=72]SPACE[/font_size][/color] TO INTERACT", "interact", 0)


func look_at_interactable(caller, enable, at=""):
	if enable:
		caller.get_node("Interactable")._different_marker = ActionManager.get_target(at, caller, self).get_node("Interactable").get_node("FocusPoint")
		self.focus_interactable(null, caller.get_node("Interactable")._different_marker.global_position)
	else:
		caller.get_node("Interactable")._different_marker = null


func rotate_focus(interactable):
	rotation.y += $Pivot/Camera3D.rotation.y
	$Pivot/Camera3D.rotation.y = 0
	reset_interactable(interactable)
	_interactable_focus = Vector3.ZERO


func rotate_interactable(caller):
	self.rotate_focus(caller)
	caller.get_node("Interactable")._different_marker = null


func reset_interactable(interactable):
	if _interactable_object == interactable:
		_interactable_object = null;
		_interactable_focus = Vector3.ZERO
		UiMessage.hide_message()


func is_looking_at(body):
	if $RayCast3D.is_colliding():
		return $RayCast3D.get_collider() == body
	return false
	
	
func take(object, time, shift=0.0):
	object.move(self.global_position + $Pivot.position / 2 + Vector3(0, shift, 0), time)
	await object.animation_ended
	animation_ended.emit()
	

func equip_gun():
	$UI.show_ui(1.5)
	$AnimationPlayer.play("Equip")
	$Pivot/Camera3D/Gun.visible = true
	await $UI.animation_ended
	$AnimationPlayer.play("Idle")
	gun_equipped = true
	animation_ended.emit()
	
	
func allow_keys(allowed_keys={}):
	for key in allowed_keys:
		self.allowed_controls[key] = allowed_keys[key]
		

func restrict_angle(min_value, max_value):
	self.restricted_angle = Vector2(min_value, max_value)


func enter_tanker():
	self.inside_hamm = false
	$BarkTimer.start(randf_range(bark_time.x, bark_time.y))


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Shoot":
		self._is_shooting = false


func _on_bark_timer_timeout() -> void:
	if not UiMessage._active:
		ActionManager.run_actions(bark_data[bark_index].data, self, self)
		bark_index = (bark_index + 1) % bark_data.size()
		$BarkTimer.start(randf_range(bark_time.x, bark_time.y))
	else:
		$BarkTimer.start(1.0)
