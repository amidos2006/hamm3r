extends CanvasLayer


func initialize(args):
	var end_actions = load(args.actions)
	ActionManager.run_actions(end_actions.data, self, null)


func pause_vhs():
	$Screen.material.set_shader_parameter("noise_opacity", 0.4)
	

func rewind_vhs():
	$Screen.material.set_shader_parameter("roll", true)
