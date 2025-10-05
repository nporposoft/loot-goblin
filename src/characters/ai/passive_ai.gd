class_name PassiveAI
extends Node

@export var map: Terrain = null
@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 2.0

@onready var character: Character = get_parent() as Character
@onready var wait_timer: Timer = _create_wait_timer()


func _process(_delta: float):
	var action := Character.Action.new()
	if character.nav_agent.is_navigation_finished():
		pass
	else:
		action.move_input = character.nav_agent.get_next_path_position() - character.global_position
		action.move_input = action.move_input.normalized()
	character.act(action)


func _pick_random_destination() -> Vector2:
	var map_size = Vector2(
		map.width * map.tile_set.tile_size.x, 
		map.height * map.tile_set.tile_size.y)
	var random_point = Vector2(
		randf_range(0, map_size.x), 
		randf_range(0, map_size.y))
	return random_point

func _create_wait_timer() -> Timer:
	var timer = Timer.new()
	timer.wait_time = randf_range(min_wait_time, max_wait_time)
	timer.one_shot = true
	add_child(timer)
	return timer
