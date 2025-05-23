extends CanvasLayer

@export var pictures:Dictionary[String, CharacterMoodPictures]
@export var tracery_grammar:JSON

var _action_button


signal _action_pressed
signal advance_dialogue


func _ready():
	hide_message()


func _input(event):
	if _action_button.length() > 0 and event.is_action_pressed(_action_button):
		_action_pressed.emit()


func _get_picture(character_name, mood):
	character_name = character_name.to_lower().strip_edges()
	assert(character_name in pictures, "ERROR: The character name (" + character_name + ") is not found")
	return pictures[character_name].get_picture(mood)


func show_message(character_name, mood, dialogue, direction = "left", time=0, action = "interact"):
	var regex = RegEx.new()
	var tracery = Tracery.Grammar.new(tracery_grammar.data)
	regex.compile("#\\w+#")
	for pattern in regex.search_all(dialogue):
		dialogue = dialogue.replace(pattern.get_string(), tracery.flatten(pattern.get_string()))
	var chatbox = $Right
	match direction:
		"left":
			chatbox = $Left
		"right":
			chatbox = $Right
	chatbox.get_node("Picture").texture = _get_picture(character_name, mood)
	chatbox.get_node("Name").text = character_name
	chatbox.get_node("Dialogue").text = dialogue
	if action.length() > 0:
		chatbox.get_node("Prompt").text = "[ " + InputMap.action_get_events(action)[0].as_text().split("(")[0].to_upper().strip_edges() + " ]"
	else:
		chatbox.get_node("Prompt").text = ""
	chatbox.show()
	
	if time > 0:
		await get_tree().create_timer(time).timeout
	else:
		_action_button = action
		await _action_pressed
	
	hide_message()
	advance_dialogue.emit()


func hide_message():
	_action_pressed.emit()
	_action_button = ""
	$Left.hide()
	$Right.hide()
