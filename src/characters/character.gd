extends CharacterBody2D

class_name Character

@export var move_speed: float = 200.0
@export var held_item: ItemData = null

@onready var _spritesheet: AnimatedSprite2D = $Spritesheet

# Action is used by controllers to interact with characters.
# Specifically -- player controller can pass to the player character,
# AI controller can pass to AI characters, etc.
class Action extends Object:
	var move_input: Vector2 = Vector2.ZERO
	var aim_direction: Vector2 = Vector2.ZERO
	var interact_target: Interactable = null
	var pickup_item: Item = null
	var drop_item: bool = false


var _aim_direction: Vector2 = Vector2.ZERO


func act(action: Action) -> void:
	_process_movement(action.move_input)
	_process_aiming(action.aim_direction)
	_process_pickup_and_drop(action)


func is_holding() -> bool:
	return held_item != null


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _process_movement(move_input: Vector2) -> void:
	velocity = move_input.normalized() * move_speed
	if is_zero_approx(velocity.length()):
		_spritesheet.play("idle")
	else:
		if velocity.x < 0:
			_spritesheet.set_flip_h(true)
		if velocity.x > 0:
			_spritesheet.set_flip_h(false)
		_spritesheet.play("run")


func _process_aiming(aim_direction: Vector2) -> void:
	_aim_direction = aim_direction.normalized()


func _process_pickup_and_drop(action: Action) -> void:
	if is_holding() and action.drop_item:
		ItemSpawner.spawn_item(held_item, global_position + _aim_direction * 10, _aim_direction * 50)
		held_item = null
	elif not is_holding() and action.pickup_item != null:
		held_item = action.pickup_item.pickup()
