class_name CharacterSprite
extends AnimatedSprite2D

@export var move_velocity_threshold: float = 1.0

@onready var character: Character = get_parent() as Character


func _process(_delta: float) -> void:
	if character.is_dead:
		play("dead")
		return

	if character._attack_state == Character.AttackState.CHARGE:
		play("attack_charge")
		return
	elif character._attack_state == Character.AttackState.SWING:
		play("attack_swing")
		return
	elif character._attack_state == Character.AttackState.RECOVER:
		play("attack_recover")
		return

	if character.linear_velocity.length() < move_velocity_threshold:
		if character.is_holding():
			play("idle_carry")
		else:
			play("idle")
		set_flip_h(character.aim_direction.x < 0)
	else:
		if character.linear_velocity.x < 0:
			set_flip_h(true)
		elif character.linear_velocity.x > 0:
			set_flip_h(false)

		if character.is_holding():
			play("run_carry")
		else:
			play("run")
