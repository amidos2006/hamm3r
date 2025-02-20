extends EditorInspectorPlugin

var example = null
var json_object = null

func _can_handle(object: Object) -> bool:
	return object is JSON
	

func _parse_end(object: Object) -> void:
	var category = Label.new()
	category.text = "TRACERY"
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
	example = TextEdit.new()
	example.placeholder_text = "Generated example will appear here"
	example.editable = false
	example.scroll_fit_content_height = true
	add_custom_control(example)
	json_object = object

func _on_generate_pressed():
	var tracery = Tracery.Grammar.new(json_object.get_data())
	example.text = tracery.flatten("#origin#")
