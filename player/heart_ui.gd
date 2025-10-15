extends Control


@export var empty_heart:Texture = null
@export var full_heart:Texture = null


func set_health(full):
	if full:
		$TextureRect.texture = full_heart
	else:
		$TextureRect.texture = empty_heart
