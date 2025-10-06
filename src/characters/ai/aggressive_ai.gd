class_name AggressiveAI
extends Node

signal state_changed(new_state: State)

enum State {
	IDLING,
	WANDERING,

	SUSPICIOUS,
	ATTACKING,

	LOOKING,
	SEARCHING
}

@export_group("Behavior")
@export var min_idle_time: float = 2.0
@export var max_idle_time: float = 10.0
@export var min_wander_distance: float = 200.0
@export var max_wander_distance: float = 600.0
@export var min_suspicious_time: float = 2.0
@export var max_suspicious_time: float = 10.0
@export var min_looking_time: float = 5.0
@export var max_looking_time: float = 10.0
@export var min_search_time: float = 30.0
@export var max_search_time: float = 60.0
@export var min_search_distance: float = 20.0
@export var max_search_distance: float = 100.0
@export var display_state_indicator: bool = true

@export_group("State")
@export var state: State = State.IDLING
@export var current_target: Character = null
@export var last_known_target_position: Vector2 = Vector2.ZERO
@export var visible_characters: Array[Character] = []

@export_group("Components")
@export var map: Terrain = null

@onready var character: Character = get_parent() as Character

@onready var _state_timer: Timer = _create_timer()
@onready var _search_timer: Timer = _create_timer()


func _ready() -> void:
	_create_state_indicator()
	_start_idling()


func _process(delta: float):
	var action := Character.Action.new()

	if current_target and _can_see(current_target):
		last_known_target_position = current_target.global_position
		
	match state:
		State.IDLING:
			var target: Character = _pick_target()
			if target != null and _want_to_attack(target):
				_start_suspicious(target)
			else:
				if _state_timer.is_stopped(): _start_wandering()
		State.WANDERING:
			var target: Character = _pick_target()
			if target != null and _want_to_attack(target):
				_start_suspicious(target)
			else:
				if character.nav_agent.is_navigation_finished():
					_start_idling()
				else:
					action.move_input = character.nav_agent.get_next_path_position() - character.global_position
					action.aim_direction = action.move_input
		State.SUSPICIOUS:
			action.aim_direction = last_known_target_position - character.global_position
			if character.near_vision.get_characters().has(current_target) and _want_to_attack(current_target):
				_start_attacking(current_target)
			else:
				if _state_timer.is_stopped():
					if _can_see(current_target):
						_start_searching()
					else:
						_start_idling()
				else:
					# just keep staring
					pass
			pass
		State.ATTACKING:
			if current_target.is_dead:
				_start_idling()
			if !_can_see(current_target):
				_start_searching()
			else:
				if _in_attack_range(current_target):
					action.aim_direction = current_target.global_position - character.global_position
					action.attack = true
				else:
					character.nav_agent.set_target_position(last_known_target_position)
					action.move_input = character.nav_agent.get_next_path_position() - character.global_position
					action.aim_direction = action.move_input
		State.LOOKING:
			var target: Character = _pick_target()
			if target != null and _want_to_attack(target):
				_start_attacking(target)
			else:
				if _search_timer.is_stopped():
					_start_idling()
				elif _state_timer.is_stopped():
					_start_searching()
				else:
					# just keep looking around
					pass
		State.SEARCHING:
			var target: Character = _pick_target()
			if target != null and _want_to_attack(target):
				_start_attacking(target)
			else:
				if _search_timer.is_stopped():
					_start_idling()
				elif character.nav_agent.is_navigation_finished():
					_start_looking()
				else:
					action.move_input = character.nav_agent.get_next_path_position() - character.global_position
					action.aim_direction = action.move_input

	character.act(action, delta)


func _physics_process(_delta: float) -> void:
	var space_state = character.get_world_2d().direct_space_state
	visible_characters.clear()
	for target in character.far_vision.get_characters():
		var query = PhysicsRayQueryParameters2D.create(character.global_position, target.global_position, 1 << 0 | 1 << 1, [character])
		var result = space_state.intersect_ray(query)
		if result.has("collider") and result["collider"] == target:
			visible_characters.append(target)


func _start_idling() -> void:
	_set_state(State.IDLING)
	_state_timer.wait_time = randf_range(min_idle_time, max_idle_time)
	_state_timer.start()


func _start_wandering() -> void:
	_set_state(State.WANDERING)
	character.nav_agent.set_target_position(_pick_random_destination(randf_range(min_wander_distance, max_wander_distance)))


func _start_suspicious(target: Character) -> void:
	_set_state(State.SUSPICIOUS)
	current_target = target
	_state_timer.wait_time = randf_range(min_suspicious_time, max_suspicious_time)
	_state_timer.start()


func _start_attacking(target: Character) -> void:
	_set_state(State.ATTACKING)
	current_target = target


func _start_looking() -> void:
	_set_state(State.LOOKING)
	current_target = null
	_state_timer.wait_time = randf_range(min_looking_time, max_looking_time)
	_state_timer.start()
	if _search_timer.is_stopped():
		_search_timer.wait_time = randf_range(min_search_time, max_search_time)
		_search_timer.start()


func _start_searching() -> void:
	_set_state(State.SEARCHING)
	current_target = null
	# pick a nearby place to walk to unless we're still walking toward the last known position
	if character.nav_agent.is_navigation_finished():
		character.nav_agent.set_target_position(_pick_random_destination(randf_range(min_search_distance, max_search_distance), last_known_target_position))
	if _search_timer.is_stopped():
		_search_timer.wait_time = randf_range(min_search_time, max_search_time)
		_search_timer.start()


func _pick_target() -> Character:
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
	return _target and !_target.is_dead


func _in_attack_range(target: Character) -> bool:
	return character.global_position.distance_to(target.global_position) < character.attack_range


func _can_see(target: Character) -> bool:
	return visible_characters.has(target)


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)


func _pick_random_destination(max_range: float = 0.0, from: Vector2 = character.global_position) -> Vector2:
	# TODO: it would probably make more sense to pick a random distance and angle
	# because 99% of the time this is just going to pick a point outside the circle and
	# then clamp it to the edge of the circle
	var tile_size: int = map.tile_set.tile_size.x
	var map_rect: Rect2 = map.get_used_rect()
	var random_point = Vector2(
		randf_range(map_rect.position.x * tile_size, map_rect.end.x * tile_size), 
		randf_range(map_rect.position.y * tile_size, map_rect.end.y * tile_size))
	if !is_zero_approx(max_range) and from.distance_to(random_point) > max_range:
		random_point = from.direction_to(random_point) * max_range + from
	return random_point


func _create_timer() -> Timer:
	var timer: Timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	return timer


func _create_state_indicator() -> void:
	if display_state_indicator:
		var indicator: StateIndicator = StateIndicator.new()
		indicator.ai_controller = self
		character.call_deferred("add_child", indicator)
		indicator.position.y -= 40
