extends Node

func _ready():
	pass
	
func get_target(name, caller, player=null):
	var target = caller
	if name.to_lower() == "player":
		target = player
	elif name.length() > 0:
		target = caller.get_node(name)
	return target
	
	
func check_condition(conditions, caller, player=null):
	var result = true
	for cond in conditions:
		var target = get_target(cond.get("target", ""), caller, player)
		result = result and target.get(cond.name) == cond.value
	return result
	
	
func run_actions(actions, caller, player=null):
	for act in actions:
		var conditions = check_condition(act.get("conditions", []), caller, player)
		if not conditions:
			continue
		
		var target = get_target(act.get("target", ""), caller, player)
		match(act.action):
			#Interactable related actions
			"look":
				if act.args.enable:
					caller.get_node("Interactable")._different_marker = get_target(act.args.get("at", ""), caller, player).get_node("Interactable").get_node("FocusPoint")
					player.focus_interactable(null, caller.get_node("Interactable")._different_marker.global_position)
				else:
					caller.get_node("Interactable")._different_marker = null
			"rotate":
				player.rotate_focus(caller)
				caller.get_node("Interactable")._different_marker = null
			
			# Generic related actions
			"show_message":
				UiMessage.show_message(act.args.message, act.args.action, act.args.time)
				target = UiMessage
				act.wait = "advance_message"
			"show_dialogue":
				Dialogue.show_message(act.args.name, act.args.mood, act.args.text, act.args.direction, act.args.time, act.args.action)
				target = Dialogue
			"switch_scene":
				SceneManager.switch_scene(act.args.path, act.args)
			"fade":
				Blackout.fade(act.args.start, act.args.end, act.args.time)
				target = Blackout
				act.wait = "animation_ended"
			
			# Target related actions
			"variable":
				target.set(act.args.name, act.args.value)
			"function":
				var args = []
				if act.args.has("object"):
					if act.args.object == "caller":
						args.append(caller)
					elif act.args.object == "target":
						args.append(target)
					elif act.args.object == "player" and player != null:
						args.append(player)
				if act.args.has("args"):
					args = args + act.args.args
				target.callv(act.args.name, args)
			"sound":
				if act.args.action.to_lower() == "play":
					if act.args.has("loop"):
						target.autoplay = act.args.loop
					target.play()
				elif act.args.action.to_lower() == "stop":
					target.stop()
				elif act.args.action.to_lower() == "volume":
					var tween = get_tree().create_tween()
					tween.tween_property(target, "volume_db", act.args.value, act.wait)
		
		if act.has("wait"):
			if typeof(act.wait) == TYPE_STRING:
				await Signal(target, act.wait)
			else:
				await get_tree().create_timer(act.wait).timeout
