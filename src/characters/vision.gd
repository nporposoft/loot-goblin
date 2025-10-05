class_name Vision
extends Detector


func get_characters() -> Array[Character]:
	var characters_in_vision: Array[Character] = []
	for character in get_all():
		if character is Character: characters_in_vision.append(character)
	return characters_in_vision

