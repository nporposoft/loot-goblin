class_name Character
extends CharacterBody2D

@export_group("Stats")
@export var move_speed: float = 200.0
@export_group("State")
@export var held_item: ItemData = null
@export_group("Components")
@export var reach: Reach = null
@export var vision: Vision = null
@export var nav_agent: NavigationAgent2D = null

var aim_direction: Vector2 = Vector2.ZERO

var _held_item_sprite: Sprite2D = null

@onready var _spritesheet: AnimatedSprite2D = $Spritesheet

# Action is used by controllers to interact with characters.
# Specifically -- player controller can pass to the player character,
# AI controller can pass to AI characters, etc.
class Action extends Object:
	var move_input: Vector2 = Vector2.ZERO
	var aim_direction: Vector2 = Vector2.ZERO
	var trigger: Trigger = null
	var pickup_item: Item = null
	var throw_force: float = 0.0


func _ready() -> void:
	_create_held_item_sprite()


func act(action: Action) -> void:
	_process_movement(action)
	_process_aiming(action)
	_process_pickup_and_drop(action)
	_process_trigger(action)


func is_holding() -> bool:
	return held_item != null


func hold_item(item: ItemData) -> void:
	held_item = item
	_create_held_item_sprite()


func remove_item() -> ItemData:
	if is_holding():
		var item = held_item
		_remove_held_item_sprite()
		held_item = null
		return item
	return null


func toss_item(throw_vector: Vector2) -> void:
	if is_holding():
		var item = remove_item()
		ItemSpawner.spawn_item(item, global_position + throw_vector.normalized() * 10, throw_vector)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _process_movement(action: Action) -> void:
	velocity = action.move_input.normalized() * move_speed
	if is_zero_approx(velocity.length()):
		if is_holding():
			_spritesheet.play("idle_carry")
		else:
			_spritesheet.play("idle")
	else:
		if velocity.x < 0:
			_spritesheet.set_flip_h(true)
		if velocity.x > 0:
			_spritesheet.set_flip_h(false)
		if is_holding():
			_spritesheet.play("run_carry")
		else:
			_spritesheet.play("run")


func _process_aiming(action: Action) -> void:
	aim_direction = action.aim_direction.normalized()


func _process_pickup_and_drop(action: Action) -> void:
	if is_holding() and !is_zero_approx(action.throw_force):
		toss_item(aim_direction * action.throw_force)
	elif not is_holding() and action.pickup_item != null:
		var items_in_reach = reach.get_items()
		if action.pickup_item in items_in_reach:
			hold_item(action.pickup_item.pickup())


func _process_trigger(action: Action) -> void:
	if action.trigger in reach.get_triggers():
		action.trigger.trigger()


func _create_held_item_sprite() -> void:
	if held_item == null: return

	if _held_item_sprite != null: _remove_held_item_sprite()

	_held_item_sprite = Sprite2D.new()
	_held_item_sprite.texture = held_item.ui_sprite
	_held_item_sprite.scale = Vector2(0.1, 0.1)
	_held_item_sprite.position = Vector2(0, -20)
	add_child(_held_item_sprite)


func _remove_held_item_sprite() -> void:
	if _held_item_sprite == null: return

	_held_item_sprite.queue_free()
	_held_item_sprite = null
