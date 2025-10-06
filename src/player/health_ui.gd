class_name HealthUI
extends Control

@export var character: Character

@onready var health_slots: Array[AnimatedSprite2D] = _get_health_slots()


func _ready() -> void:
	character.health_changed.connect(_handle_health_changed)


func _handle_health_changed() -> void:
	for i in health_slots.size():
		var slot = health_slots[i]
		if i < character.current_health:
			if slot.animation == "pop":
				slot.play("regrow")
				# HACK: automatically go back to idle after regrow
				slot.animation_finished.connect(func() -> void:
					if slot.animation == "regrow":
						slot.play("idle"))
		else:
			if slot.animation != "pop":
				slot.play("pop")


func _get_health_slots() -> Array[AnimatedSprite2D]:
	var slots: Array[AnimatedSprite2D] = []
	for child in get_children():
		if child is AnimatedSprite2D:
			slots.append(child)
	return slots
