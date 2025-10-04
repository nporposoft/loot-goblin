class_name PlayerCharacterController
extends Node

@export var character: Character = null
@export var max_throw_charge_time: float = 3.0
@export var throw_force_multiplier: float = 200.0

var _throw_charge_time: float = 0.0
var _charging_throw: bool = false


func _process(_delta: float) -> void:
	if not _has_character():
		return

	if _charging_throw:
		_throw_charge_time += _delta

	var action = Character.Action.new()
	action.move_input = _get_move_input()
	action.aim_direction = _get_aim_direction()

	if Input.is_action_just_pressed("dodge"):
		pass
	elif Input.is_action_just_pressed("interact"):
		action.interact_target = _get_interact_target()
	elif Input.is_action_just_pressed("pickup") and !character.is_holding():
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
		return null
	else:
		return null


func _get_item_target() -> Item:
	if _is_mouse_aiming():
		var query = PhysicsPointQueryParameters2D.new()
		query.position = _get_mouse_position()
		query.collision_mask = 1 << 2
		var space_state = character.get_world_2d().direct_space_state
		var result = space_state.intersect_point(query)
		for hit in result:
			var collider = hit.collider
			if collider is Item:
				return collider
		return null
	else:
		return null


func _get_mouse_position() -> Vector2:
	return character.get_global_mouse_position()


func _is_mouse_aiming() -> bool:
	# todo maybe?
	return true
