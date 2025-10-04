extends CharacterBody2D

class_name Character

@export var move_speed: float = 200.0
@export var held_item: ItemData = null

# Action is used by controllers to interact with characters.
# Specifically -- player controller can pass to the player character,
# AI controller can pass to AI characters, etc.
class Action extends Object:
	var move_input: Vector2 = Vector2.ZERO
	var aim_direction: Vector2 = Vector2.ZERO
	var interact_target: Interactable = null


var _last_action: Action = null


func act(action: Action) -> void:
	_last_action = action


func stop() -> void:
	_last_action = null


func get_vision_collider() -> CollisionShape2D:
	return $VisionCollider


func _process(delta: float) -> void:
	# NOTE: is it a good idea to separate processing from action? seems maybe okay
	# but there might be some async weirdness?
	if is_instance_valid(_last_action):
		_process_movement(_last_action.move_input, delta)
		_process_aiming(_last_action.aim_direction)
		_process_interaction(_last_action.interact_target)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _process_movement(move_input: Vector2, delta: float) -> void:
	velocity = move_input.normalized() * move_speed


func _process_aiming(_aim_direction: Vector2) -> void:
	pass


func _process_interaction(_interact_target: Interactable) -> void:
	pass
