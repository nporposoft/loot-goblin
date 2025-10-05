class_name AggressiveAI
extends Node

enum State {
	IDLING,
	WANDERING,
	SUSPICIOUS,
	ALERTING,
	ATTACKING,
	SEARCHING
}

@export_group("Behavior")
@export var min_search_time: float = 5.0
@export var max_search_time: float = 10.0
@export var min_idle_time: float = 2.0
@export var max_idle_time: float = 10.0
@export var min_alert_time: float = 0.0
@export var max_alert_time: float = 2.0

@export_group("State")
@export var state: State = State.IDLING
@export var current_target: Character = null
@export var last_known_target_position: Vector2 = Vector2.ZERO
@export var visible_characters: Array[Character] = []

@export_group("Components")
@export var map: Terrain = null

@onready var character: Character = get_parent() as Character

@onready var _timer: Timer = _create_timer()


func _process(_delta: float):
	var action := Character.Action.new()

	match state:
		State.IDLING:
			var target: Character = _find_nearest_visible_target()
			if target != null:
				_start_attacking(target)
			else:
				if _timer.is_stopped(): _start_wandering()
		State.WANDERING:
			var target: Character = _find_nearest_visible_target()
			if target != null:
				_start_attacking(target)
			else:
				if character.nav_agent.is_navigation_finished():
					_start_idling()
				else:
					action.move_input = character.nav_agent.get_next_path_position() - character.global_position
		State.SUSPICIOUS:
			action.aim_direction = (last_known_target_position - character.global_position).normalized()
			# TODO
			pass
		State.ALERTING:
			if _can_reach(current_target):
				_start_attacking(current_target)
			else:
				if _timer.is_stopped():
					_start_searching()
		State.ATTACKING:
			if !_can_see(current_target):
				_start_searching()
			else:
				last_known_target_position = current_target.global_position
				if _can_reach(current_target):
					action.aim_direction = (current_target.global_position - character.global_position).normalized()
					action.attack = true
				else:
					character.nav_agent.set_target_position(current_target.global_position)
					action.move_input = character.nav_agent.get_next_path_position() - character.global_position
		State.SEARCHING:
			var target: Character = _find_nearest_visible_target()
			if target != null:
				_start_attacking(target)

	character.act(action)


func _process_physics(_delta: float) -> void:
	var space_state = character.get_world_2d().direct_space_state
	visible_characters.clear()
	for target in character.vision.get_characters():
		var query = PhysicsRayQueryParameters2D.create(character.global_position, target.global_position, 1 << 0 | 1 << 1, [character])
		var result = space_state.intersect_ray(query)
		if result["collider"] == target:
			visible_characters.append(target)


func _start_idling() -> void:
	state = State.IDLING
	_timer.wait_time = randf_range(min_idle_time, max_idle_time)
	_timer.start()


func _start_wandering() -> void:
	state = State.WANDERING
	character.nav_agent.set_target_position(_pick_random_destination())


func _start_attacking(target: Character) -> void:
	state = State.ATTACKING
	current_target = target
	last_known_target_position = target.global_position


func _start_alerting(target: Character) -> void:
	state = State.ALERTING
	current_target = target
	last_known_target_position = target.global_position
	_timer.wait_time = randf_range(min_search_time, max_search_time)
	_timer.start()


func _start_searching() -> void:
	state = State.SEARCHING
	_timer.wait_time = randf_range(min_search_time, max_search_time)
	_timer.start()


func _find_nearest_visible_target() -> Character:
	var nearest_target: Character = null
	var nearest_distance: float = INF

	for target in visible_characters:
		if !_want_to_attack(target):
			continue

		var distance: float = character.global_position.distance_to(target.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = target

	return nearest_target


func _want_to_attack(_target: Character) -> bool:
	# TODO
	return true


func _can_reach(target: Character) -> bool:
	return character.reach.get_characters().has(target)


func _can_see(target: Character) -> bool:
	return visible_characters.has(target)


func _pick_random_destination(max_range: float = 0.0) -> Vector2:
	var tile_size: int = map.tile_set.tile_size.x
	var map_rect: Rect2 = map.get_used_rect()
	var random_point = Vector2(
		randf_range(map_rect.position.x * tile_size, map_rect.end.x * tile_size), 
		randf_range(map_rect.position.y * tile_size, map_rect.end.y * tile_size))
	if !is_zero_approx(max_range) and character.global_position.distance_to(random_point) > max_range:
		random_point = character.global_position.direction_to(random_point) * max_range + character.global_position
	return random_point


func _create_timer() -> Timer:
	var timer: Timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	return timer

