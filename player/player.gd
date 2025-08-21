extends CharacterBody3D


@export var movement_speed = 4
@export var backward_ratio = 0.4
@export var rotation_speed = 5
@export var gravity = 4


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


signal angle_left
signal angle_right


var _interactable_object = null
var _interactable_focus = Vector3.ZERO
var _target_velocity = Vector3.ZERO


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
		else:
			pass
	
	if direction != 0:
		rotate_y(direction * rotation_speed * PI / 360)
		if restricted_angle != null:
			rotation_degrees.y = clamp(rotation_degrees.y, restricted_angle.x, restricted_angle.y)
		if rotation_degrees.y > 100:
			angle_left.emit()
		if rotation_degrees.y < -90:
			angle_right.emit()
	
	var forward = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	_target_velocity.x = (forward * movement * movement_speed).x
	_target_velocity.z = (forward * movement * movement_speed).z
	_target_velocity.y -= delta * gravity
	if is_on_floor():
		_target_velocity.y = 0
	velocity = _target_velocity
		
	move_and_slide()
	
	# we need to make function for rotating and looking
	$Pivot/Camera3D.rotation = lerp($Pivot/Camera3D.rotation, _interactable_focus, 0.1)
	
	
func focus_interactable(interactable, focus_point):
	_interactable_object = interactable
	_interactable_focus = _get_rotation(focus_point)
	if _interactable_object and not _interactable_object.get_node("Interactable").disable_interaction:
		UiMessage.show_message("PRESS [color=#d1ff85][font_size=72]SPACE[/font_size][/color] TO INTERACT", "interact", 0)
	

func reset_interactable(interactable):
	if _interactable_object == interactable:
		_interactable_object = null;
		_interactable_focus = Vector3.ZERO
		UiMessage.hide_message()


func is_looking_at(body):
	if $RayCast3D.is_colliding():
		return $RayCast3D.get_collider() == body
	return false
