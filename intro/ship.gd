extends RigidBody2D


signal ship_docked


var _active
var _exit_active
var _action
var _last_speed
var _thruster_power
var _thruster_acc
var _thruster_dec
var _thruster_force
var _attraction_force
var _direction


func _ready():
	_attraction_force = 0
	_thruster_force = 0
	_thruster_power = 0
	_thruster_dec = 0
	_thruster_acc = 0
	_direction = Vector2.ZERO
	_active = false
	_exit_active = false


func _process(delta):
	_last_speed = linear_velocity.length()
	
	if _thruster_power == 0:
		$AnimationSprite.play("none")
	elif _thruster_power < 0.3:
		$AnimationSprite.play("low")
	elif _thruster_power < 0.7:
		$AnimationSprite.play("medium")
	else:
		$AnimationSprite.play("high")
	$FrontParticlesLeft.emitting = _thruster_power > 0
	$FrontParticlesLeft.emission_sphere_radius = 4 + _thruster_power * 6
	$FrontParticlesLeft.initial_velocity_min = _last_speed + 20
	$FrontParticlesLeft.initial_velocity_max = _last_speed + 40
	$FrontParticlesRight.emitting = $FrontParticlesLeft.emitting
	$FrontParticlesRight.emission_sphere_radius = $FrontParticlesLeft.emission_sphere_radius
	$FrontParticlesRight.initial_velocity_min = $FrontParticlesLeft.initial_velocity_min
	$FrontParticlesRight.initial_velocity_max = $FrontParticlesLeft.initial_velocity_max
	
	_thruster_power = clamp(_thruster_power - _thruster_dec * delta, 0, 1)
	apply_force(_direction * _attraction_force)
	if _thruster_power > 0:
		apply_force(-_direction * _thruster_force * _thruster_power)	
	
	if (_active and Input.is_action_pressed(_action)) or _exit_active:
		_thruster_power = clamp(_thruster_power + _thruster_acc * delta, 0, 1)


func start_moving(start_speed, attraction_force, thruster_force, thruster_acc, thruster_dec, action, station_pos):
	_direction = Vector2(station_pos.x - position.x, station_pos.y - position.y)
	_direction = _direction.normalized()
	linear_velocity = _direction * start_speed
	_attraction_force = attraction_force
	
	_thruster_force = thruster_force
	_thruster_acc = thruster_acc
	_thruster_dec = thruster_dec
	
	_action = action
	_active = true


func ship_exit(attraction_force, thruster_force, thruster_acc, thruster_dec, time):
	_attraction_force = attraction_force
	_thruster_force = thruster_force
	_thruster_acc = thruster_acc
	_thruster_dec = thruster_dec
	_exit_active = true
	
	var cargo = $Cargo
	self.remove_child(cargo)
	get_parent().add_child(cargo)
	cargo.position += position
	await get_tree().create_timer(time).timeout
	ship_docked.emit()


func _on_body_entered(body):
	if _active:
		ship_docked.emit(_last_speed)
	_active = false


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if _active:
		ship_docked.emit(-1000)
	_active = false
