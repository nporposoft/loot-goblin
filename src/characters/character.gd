class_name Character
extends CharacterBody2D

@export var move_speed: float = 200.0
@export var held_item: ItemData = null

var aim_direction: Vector2 = Vector2.ZERO

@onready var _spritesheet: AnimatedSprite2D = $Spritesheet

# Action is used by controllers to interact with characters.
# Specifically -- player controller can pass to the player character,
# AI controller can pass to AI characters, etc.
class Action extends Object:
	var move_input: Vector2 = Vector2.ZERO
	var aim_direction: Vector2 = Vector2.ZERO
	var interact_target: Interactable = null
	var pickup_item: Item = null
	var throw_force: float = 0.0


func act(action: Action) -> void:
	_process_movement(action)
	_process_aiming(action)
	_process_pickup_and_drop(action)


func is_holding() -> bool:
	return held_item != null


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _process_movement(action: Action) -> void:
	velocity = action.move_input.normalized() * move_speed
	if is_zero_approx(velocity.length()):
		_spritesheet.play("idle")
	else:
		if velocity.x < 0:
			_spritesheet.set_flip_h(true)
		if velocity.x > 0:
			_spritesheet.set_flip_h(false)
		_spritesheet.play("run")


func _process_aiming(action: Action) -> void:
	aim_direction = action.aim_direction.normalized()


func _process_pickup_and_drop(action: Action) -> void:
	if is_holding() and !is_zero_approx(action.throw_force):
		ItemSpawner.spawn_item(held_item, global_position + action.aim_direction * 10, action.aim_direction * action.throw_force)
		held_item = null
	elif not is_holding() and action.pickup_item != null:
		held_item = action.pickup_item.pickup()
