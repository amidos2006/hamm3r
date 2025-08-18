extends CharacterBody3D


@export var movement_speed = 4
@export var backward_ratio = 0.4
@export var rotation_speed = 5
@export var gravity = 4
@export var disable_controls = true

var _interactable_object = null
var _interactable_focus = Vector3.ZERO
var _target_velocity = Vector3.ZERO


func _physics_process(delta):
	var movement = 0
	var direction = 0
	if !disable_controls:
		if Input.is_action_pressed("forward"):
			movement -= 1
		elif Input.is_action_pressed("backward"):
			movement += backward_ratio
		
		if Input.is_action_pressed("right"):
			direction -= 1
		elif Input.is_action_pressed("left"):
			direction += 1
			
		if Input.is_action_just_pressed("interact"):
			if _interactable_object != null:
				_interactable_object.get_node("Interactable").interact(self)
			else:
				pass
	
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
	
	# we need to make function for rotating and looking
	#$Pivot/Camera3D.look_at(focus_point, Vector3.UP, true)
	
	
func focus_interactable(interactable, focus_point):
	_interactable_object = interactable
	_interactable_focus = focus_point
	

func reset_interactable(interactable):
	if _interactable_object == interactable:
		_interactable_object = null;
		_interactable_focus = Vector3.ZERO


func is_looking_at(body):
	if $RayCast3D.is_colliding():
		return $RayCast3D.get_collider() == body
	return false
