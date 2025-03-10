extends EditorInspectorPlugin

var mission_object = null

func _can_handle(object: Object) -> bool:
	return object is Mission
	
func _parse_end(object: Object) -> void:
	mission_object = object
	var category = Label.new()
	category.text = "Mission Graph Generator"
	category.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	category.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var style = StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.set_content_margin_all(10.0)
	category.add_theme_stylebox_override("normal", style)
	var font  = SystemFont.new();
	font.font_weight = 1000;
	category.add_theme_font_override("font", font);
	add_custom_control(category)
	var button = Button.new()
	button.text = "Generate"
	button.pressed.connect(_on_generate_pressed)
	add_custom_control(button)

func _on_generate_pressed() -> void:
	MissionGenerator.verbose = mission_object.verbose
	var graph = MissionGenerator.generate_dungeon(mission_object.start_graph, mission_object.recipe, mission_object.patterns, mission_object.max_children)
	print(str(graph))
	
