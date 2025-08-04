extends CharacterBody3D


@export var movement_speed = 4
@export var backward_ratio = 0.4
@export var rotation_speed = 5
@export var gravity = 4


var _interactable_object = null
var _target_velocity = Vector3.ZERO


func _physics_process(delta):
	var movement = 0
	if Input.is_action_pressed("forward"):
		movement -= 1
	elif Input.is_action_pressed("backward"):
		movement += backward_ratio
	
	var direction = 0
	if Input.is_action_pressed("right"):
		direction -= 1
	elif Input.is_action_pressed("left"):
		direction += 1
	
	if direction != 0:
		rotate_y(direction * rotation_speed * PI / 360)
	
	var forward = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	_target_velocity.x = (forward * movement * movement_speed).x
	_target_velocity.z = (forward * movement * movement_speed).z
	_target_velocity.y -= delta * gravity
	if is_on_floor():
		_target_velocity.y = 0
	velocity = _target_velocity
		
	move_and_slide()
	
	
func look_at_interactable(focus_point):
	$Pivot/Camera3D.look_at(focus_point, Vector3.UP, true)
	

func reset_looking():
	$Pivot/Camera3D.rotation = Vector3.ZERO


func is_looking_at(body):
	if $RayCast3D.is_colliding():
		return $RayCast3D.get_collider() == body
	return false
