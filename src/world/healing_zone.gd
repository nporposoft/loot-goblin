class_name HealingZone
extends Detector

@export var heal_speed_seconds: float = 0.5


func _ready() -> void:
	_create_heal_timer()


func _heal() -> void:
	for character in get_characters():
		character.heal(1)


func _create_heal_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = heal_speed_seconds
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_heal)
	add_child(timer)
