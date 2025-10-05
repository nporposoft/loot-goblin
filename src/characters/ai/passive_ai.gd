class_name PassiveAI
extends Node

@export var map: Terrain = null
@export var min_wait_time: float = 2.0
@export var max_wait_time: float = 10.0

@onready var character: Character = get_parent() as Character

var _time_until_next_move: float = _random_wait_time()

func _process(_delta: float):
	var action := Character.Action.new()
	if character.nav_agent.is_navigation_finished():
		if _time_until_next_move <= 0.0:
			character.nav_agent.set_target_position(_pick_random_destination())
			_time_until_next_move = _random_wait_time()
		else:
			_time_until_next_move -= _delta
	else:
		action.move_input = character.nav_agent.get_next_path_position() - character.global_position
		action.move_input = action.move_input.normalized()
	character.act(action)


func _random_wait_time() -> float:
	return randf_range(min_wait_time, max_wait_time)


func _pick_random_destination() -> Vector2:
	var tile_size: int = map.tile_set.tile_size.x
	var map_rect: Rect2 = map.get_used_rect()
	var random_point = Vector2(
		randf_range(map_rect.position.x * tile_size, map_rect.end.x * tile_size), 
		randf_range(map_rect.position.y * tile_size, map_rect.end.y * tile_size))
	return random_point
