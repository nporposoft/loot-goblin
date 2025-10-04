extends CharacterBody2D

class_name Character

@export var move_speed: float = 200.0
@export var held_item: ItemData = null
@export var carried_items: Array[ItemData] = []

var _last_action: Action = null


func act(action: Action) -> void:
	_last_action = action


func stop() -> void:
	_last_action = null


func _process(delta_time: float) -> void:
	# NOTE: is it a good idea to separate processing from action? seems maybe okay
	# but there might be some async weirdness?
	if is_instance_valid(_last_action):
		_process_movement(_last_action.move_input, delta_time)
		_process_aiming(_last_action.aim_direction)
		_process_interaction(_last_action.interact_target)


func _process_movement(move_input: Vector2, delta_time: float) -> void:
	if move_input != Vector2.ZERO:
		var movement = move_input * move_speed * delta_time
		position += movement


func _process_aiming(_aim_direction: Vector2) -> void:
	pass


func _process_interaction(_interact_target: Interactable) -> void:
	pass
