extends CanvasLayer


var _ignore_release


func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	_ignore_release = false
	

func is_paused():
	return get_tree().paused
	
	
func pause():
	get_tree().paused = true
	self.visible = true
	
	
func unpause():
	$RestartTimer.stop()
	get_tree().paused = false
	self.visible = false


func _process(_delta):
	if Input.is_action_just_released("pause"):
		if _ignore_release:
			_ignore_release = false
		else:
			if self.is_paused():
				self.unpause()
			else:
				self.pause()
	if self.is_paused():
		if Input.is_action_pressed("pause"):
			if $RestartTimer.is_stopped():
				$RestartTimer.start()
		else:
			$RestartTimer.stop()
	if not $RestartTimer.is_stopped():
		$Info/TimerFill.scale.x = 1 - $RestartTimer.time_left / $RestartTimer.wait_time
	else:
		$Info/TimerFill.scale.x = 0


func _on_restart_timer_timeout():
	self.unpause()
	_ignore_release = true
	SceneManager.switch_scene("res://intro/intro.tscn", {})
