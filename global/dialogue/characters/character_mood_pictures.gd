extends Resource
class_name CharacterMoodPictures

@export var moods:Dictionary[String, CharacterPictures]
@export var default:CharacterPictures

func get_picture(mood):
	mood = mood.to_lower().strip_edges()
	for internal in moods:
		if mood == internal.to_lower().strip_edges():
			return moods[mood].pictures.pick_random()
	return default.pictures.pick_random()
