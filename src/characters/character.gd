class_name Character
extends RigidBody2D

enum AttackState {
	READY,
	CHARGE,
	SWING,
	RECOVER,
}

enum Faction {
	GOBLIN,
	MONSTER,
	ADVENTURER,
}

signal died
signal health_changed

@export_group("Stats")
@export var faction: Faction = Faction.GOBLIN
@export var enemies: Array[Faction] = []
@export var move_speed: float = 30000.0
@export var max_health: int = 4
@export var attack_damage: int = 1
@export var attack_range: float = 64.0
@export var attack_impulse_strength: float = 100000.0
@export var attack_charge_time: float = 0.5
@export var attack_swing_time: float = 0.5
@export var attack_recover_time: float = 1.0

@export_group("State")
@export var held_item: ItemData = null
@export var is_dead: bool = false
@export var is_invisible: bool = false

var _aim_direction: Vector2 = Vector2.ZERO
var _held_item_sprite: Sprite2D = null
var _attack_state: AttackState = AttackState.READY
var _last_action: Action = null

@onready var nav_agent := $NavigationAgent2D
@onready var reach := $ReachArea
@onready var far_vision := $FarVisionArea
@onready var near_vision := $NearVisionArea
@onready var sleep_area := $SleepArea
@onready var blood_particles := $BloodParticles
@onready var attack_timer: Timer = _create_timer()
@onready var current_health: int = max_health


# Action is used by controllers to interact with characters.
# Specifically -- player controller can pass to the player character,
# AI controller can pass to AI characters, etc.
class Action extends Object:
	var move_input: Vector2 = Vector2.ZERO
	var aim_direction: Vector2 = Vector2.ZERO

	var trigger: Trigger = null

	var pickup_item: Item = null

	var throw: bool = false
	var throw_force: float = 0.0

	var attack: bool = false
	var cancel_attack: bool = false


func _ready() -> void:
	_create_held_item_sprite()

	# handle collisions for taking damage
	body_entered.connect(_handle_collision)

	# rigidbody settings
	gravity_scale = 0.0
	lock_rotation = true
	linear_damp = 15.0
	contact_monitor = true


func act(action: Action, _delta: float) -> void:
	if is_dead: return

	_process_aiming(action)
	_process_pickup_and_drop(action)
	_process_trigger(action)
	_process_attack(action)
	_last_action = action


func is_holding() -> bool:
	return held_item != null


func all_items() -> Array[ItemData]:
	var items = []
	if held_item != null:
		items.append(held_item)
	if held_item != null and held_item.is_container:
		items.append_array(held_item.items)
	return items


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


func heal(amount: int) -> void:
	if is_dead: return

	current_health = min(current_health + amount, max_health)
	health_changed.emit()


func take_damage(amount: int, force_direction: Vector2 = Vector2.ZERO) -> void:
	force_direction = force_direction.normalized()
	current_health -= amount

	blood_particles.emitting = true
	blood_particles.rotation = force_direction.angle()
	apply_central_impulse(force_direction * 10)

	health_changed.emit()

	if current_health <= 0:
		die(force_direction)


func die(force_direction: Vector2 = Vector2.ZERO) -> void:
	is_dead = true

	# stop attacking when you're dead
	_attack_state = AttackState.READY

	# drop held item
	var toss_direction = force_direction
	if force_direction.is_zero_approx():
		toss_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	if is_holding(): toss_item(toss_direction * 50)

	# disable collision with other characters
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)

	# ragdoll sort of
	lock_rotation = false
	# TODO: this doesn't do anything
	# I think the lock_rotation change doesn't apply until the next physics frame
	apply_torque_impulse(randf_range(-5000.0, 5000.0))

	died.emit()


func toss_item(throw_vector: Vector2) -> void:
	if is_holding():
		var item = remove_item()
		ItemSpawner.spawn_item(item, global_position + throw_vector.normalized() * 10, throw_vector)


func _physics_process(_delta: float) -> void:
	if _last_action == null: return
	if !_can_move(): return

	apply_central_force(_last_action.move_input.normalized() * move_speed)


func _process_aiming(action: Action) -> void:
	if !_can_change_direction(): return

	if not action.aim_direction.is_zero_approx():
		_aim_direction = action.aim_direction.normalized()


func _process_pickup_and_drop(action: Action) -> void:
	if is_holding() and held_item.is_container and held_item.items.size() < held_item.capacity and action.pickup_item != null and !action.pickup_item.item_data.is_container:
		var items_in_reach = reach.get_items()
		if action.pickup_item in items_in_reach:
			held_item.add_item(action.pickup_item.pickup())
	if is_holding() and action.throw:
		toss_item(_aim_direction * action.throw_force)
	elif not is_holding() and action.pickup_item != null:
		var items_in_reach = reach.get_items()
		if action.pickup_item in items_in_reach:
			hold_item(action.pickup_item.pickup())


func _process_trigger(action: Action) -> void:
	if action.trigger in reach.get_triggers():
		action.trigger.trigger()


func _process_attack(action: Action) -> void:
	match _attack_state:
		AttackState.READY:
			if action.attack:
				_attack_state = AttackState.CHARGE
				attack_timer.start(attack_charge_time)
		AttackState.CHARGE:
			if action.cancel_attack:
				_attack_state = AttackState.READY
			elif attack_timer.is_stopped():
				_attack_state = AttackState.SWING
				attack_timer.start(attack_swing_time)
				apply_central_impulse(_aim_direction * attack_impulse_strength)
				# HACK: immediately damage enemies in reach
				# because if they are already touching, there's no collision event to catch
				for nearby_character in reach.get_characters():
					if nearby_character == self: continue
					nearby_character.take_damage(attack_damage, nearby_character.global_position - global_position)
		AttackState.SWING:
			# TODO: damage enemies in reach but only once
			if attack_timer.is_stopped():
				_attack_state = AttackState.RECOVER
				attack_timer.start(attack_recover_time)
		AttackState.RECOVER:
			if attack_timer.is_stopped():
				_attack_state = AttackState.READY


func _handle_collision(body: Node) -> void:
	if body is Character:
		var other: Character = body
		if other._attack_state == AttackState.SWING:
			var force_direction = (global_position - other.global_position)
			# defer this call so it doesn't happen during collision processing
			call_deferred("take_damage", other.attack_damage, force_direction)
	elif is_dead:
		# emit blood when body hits something
		blood_particles.emitting = true


func _can_move() -> bool:
	return ![AttackState.CHARGE, AttackState.SWING, AttackState.RECOVER].has(_attack_state)


func _can_change_direction() -> bool:
	return ![AttackState.CHARGE, AttackState.SWING].has(_attack_state)


func _create_held_item_sprite() -> void:
	if held_item == null: return

	if _held_item_sprite != null: _remove_held_item_sprite()

	_held_item_sprite = Sprite2D.new()
	_held_item_sprite.texture = held_item.ui_sprite
	_held_item_sprite.position = Vector2(0, -16)
	add_child(_held_item_sprite)


func _remove_held_item_sprite() -> void:
	if _held_item_sprite == null: return

	_held_item_sprite.queue_free()
	_held_item_sprite = null


func _create_timer() -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	return timer

#func get_pickup_action_item(action: Action) -> ItemData:
	#if action.pickup_item != null:
		#return action.pickup_item.pickup()
	#print_debug("action.pickup_item was null...")
	#return null
