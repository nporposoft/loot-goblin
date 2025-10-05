class_name CharacterClickController
extends Node

@export var character: Character = null

func _process(_delta: float):
	if character == null:
		return
	
	if Input.is_action_just_pressed("pickup"):
		var mouse_position = character.get_global_mouse_position()
		character.nav_agent.set_target_position(mouse_position)
	
	var action := Character.Action.new()
	if !character.nav_agent.is_navigation_finished():
		var next_path_position := character.nav_agent.get_next_path_position()
		action.move_input = next_path_position - character.global_position
	character.act(action)
