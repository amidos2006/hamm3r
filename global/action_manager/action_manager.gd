extends Node


var _running_actions = false
var _stop_actions = false


func get_target(type, caller, player=null):
	var target = caller
	if type.to_lower() == "player":
		target = player
	elif type.length() > 0:
		target = caller.get_node(type)
	return target
	
	
func check_condition(conditions, caller, player=null):
	var result = true
	for cond in conditions:
		var target = get_target(cond.get("target", ""), caller, player)
		result = result and target.get(cond.name) == cond.value
	return result
	
	
func stop_actions():
	if _running_actions:
		_stop_actions = true
	
	
func run_actions(actions, caller, player=null):
	_running_actions = true
	for act in actions:
		var conditions = check_condition(act.get("conditions", []), caller, player)
		if not conditions:
			continue
		
		if _stop_actions:
			_stop_actions = false
			return
		
		var target = get_target(act.get("target", ""), caller, player)
		match(act.action):
			# Generic related actions
			"show_message":
				UiMessage.show_message(act.args.message, act.args.action, act.args.time)
				target = UiMessage
			"hide_message":
				UiMessage.hide_message()
				target = UiMessage
			"show_dialogue":
				Dialogue.show_message(act.args.name, act.args.mood, act.args.text, act.args.direction, act.args.time, act.args.action)
				target = Dialogue
			"hide_dialogue":
				Dialogue.hide_message()
				target = Dialogue
			"switch_scene":
				SceneManager.switch_scene(act.args.path, act.args)
			"fade":
				Blackout.fade(act.args.start, act.args.end, act.args.time)
				target = Blackout
				act.wait = "animation_ended"
			"open":
				Blackout.open(act.args.start, act.args.end, act.args.time)
				target = Blackout
				act.wait = "animation_ended"
			
			# Target related actions
			"variable":
				if act.args.has("signal"):
					var signal_target = target
					if act.args.has("target"):
						signal_target = get_target(act.args.target, caller, player)
					target.set(act.args.name, await Signal(signal_target, act.args.signal))
				else:
					target.set(act.args.name, act.args.value)
			"function":
				var args = []
				if act.args.has("object"):
					var temp_obj = act.args.object
					if typeof(temp_obj) != TYPE_ARRAY:
						temp_obj = [act.args.object]
					for obj in temp_obj:
						if obj == "caller":
							args.append(caller)
						elif obj == "target":
							args.append(target)
						elif obj == "player" and player != null:
							args.append(player)
						else:
							args.append(get_target(obj, caller, player))
				if act.args.has("args"):
					args = args + act.args.args
				target.callv(act.args.name, args)
			"sound":
				if act.args.name.to_lower() == "play":
					target.play()
				elif act.args.name.to_lower() == "stop":
					target.stop()
				elif act.args.name.to_lower() == "volume":
					if act.args.has("time") and act.args.time > 0:
						var tween = get_tree().create_tween()
						tween.tween_property(target, "volume_db", act.args.value, act.args.time)
					else:
						target.volume_db = act.args.value
		
		if act.has("wait"):
			if typeof(act.wait) == TYPE_STRING:
				await Signal(target, act.wait)
			else:
				await get_tree().create_timer(act.wait, false).timeout
	_running_actions = false
