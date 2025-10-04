class_name PlayerCharacterController
extends Node

@export var character: Character = null
@export var max_throw_charge_time: float = 3.0
@export var throw_force_multiplier: float = 200.0

var _throw_charge_time: float = 0.0
var _charging_throw: bool = false
var _interact_target: Interactable = null


func _process(_delta: float) -> void:
	if not _has_character():
		return

	# safety check if interact target gets deleted for some reason
	if _interact_target != null and not is_instance_valid(_interact_target):
		_interact_target = null

	# toggle interaction if the target is no longer in reach
	if _interact_target != null:
		if !character.reach.get_interactables().has(_interact_target):
			_interact_target.interact(self)
			_interact_target = null

	if Input.is_action_just_pressed("interact"):
		# if already interacting with something, stop interacting
		if _interact_target != null and is_instance_valid(_interact_target):
			_interact_target.interact(self)
			_interact_target = null
		else:
			# interact if there's a target in reach
			_interact_target = _get_interact_target()
			if _interact_target != null: _interact_target.interact(self)

	var action = Character.Action.new()
	action.move_input = _get_move_input()
	action.aim_direction = _get_aim_direction()

	if Input.is_action_just_pressed("dodge"):
		# TODO
		pass

	# Only process pickup/throw if an interaction is not already happening
	if _interact_target == null:
		if _charging_throw: _throw_charge_time += _delta

		if Input.is_action_just_pressed("pickup") and !character.is_holding():
			action.pickup_item = _get_item_target()
		elif Input.is_action_just_pressed("pickup") and character.is_holding():
			_charging_throw = true
			pass
		elif Input.is_action_just_released("pickup") and character.is_holding():
			_throw_charge_time = clamp(_throw_charge_time, 0.0, max_throw_charge_time)
			action.throw_force = _throw_charge_time**2 * throw_force_multiplier
			_charging_throw = false
			_throw_charge_time = 0.0

	character.act(action)


func _has_character() -> bool:
	return is_instance_valid(character)


func _get_move_input() -> Vector2:
	var move_input: Vector2
	move_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_input.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return move_input


func _get_aim_direction() -> Vector2:
	if _is_mouse_aiming():
		var mouse_position = _get_mouse_position()
		return (mouse_position - character.global_position).normalized()
	else:
		var aim_input: Vector2
		aim_input.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
		aim_input.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
		return aim_input.normalized()


func _get_interact_target() -> Interactable:
	if _is_mouse_aiming():
		var interactable_under_mouse = _get_interactable_under_mouse()
		if interactable_under_mouse in character.reach.get_interactables():
			return interactable_under_mouse
	else:
		# TODO: raycast in aim direction to find interactable
		pass

	return null


func _get_item_target() -> Item:
	if _is_mouse_aiming():
		var item_under_mouse = _get_item_under_mouse()
		if item_under_mouse in character.reach.get_items():
			return item_under_mouse
	else:
		# TODO: raycast in aim direction to find item
		pass

	return null


func _get_interactable_under_mouse() -> Interactable:
	for hit in _get_mouse_collisions(4):
		var collider = hit.collider
		if collider is Interactable:
			return collider
	return null


func _get_item_under_mouse() -> Item:
	for hit in _get_mouse_collisions(3):
		var collider = hit.collider
		if collider is Item:
			return collider
	return null


func _get_mouse_collisions(layer: int) -> Array[Dictionary]:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = _get_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1 << layer - 1
	var space_state = character.get_world_2d().direct_space_state
	return space_state.intersect_point(query)


func _get_mouse_position() -> Vector2:
	return character.get_global_mouse_position()


func _is_mouse_aiming() -> bool:
	# todo maybe?
	return true
