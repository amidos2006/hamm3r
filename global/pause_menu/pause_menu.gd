extends CanvasLayer


var _ignore_release


signal restart_signal


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
			$PauseSound.play()
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
	
	
func restart():
	Blackout.start()
	ActionManager.active = false
	restart_signal.emit()
	Dialogue.hide_message()
	UiMessage.hide_message()
	await get_tree().create_timer(0.1).timeout
	ActionManager.active = true
	SceneManager.execute_scene()
	
	
func _on_restart_timer_timeout():
	self.unpause()
	_ignore_release = true
	SceneManager.switch_scene("res://intro/intro.tscn", {}, restart)
