class_name FollowCamera
extends Camera2D

@export var target: Node2D
@export var follow_strength: float = 0.8


func _ready():
	if target == null:
		push_error("FollowCamera: Target is not assigned.")
		return

	position = target.position


func _process(_delta: float) -> void:
	if target == null:
		return

	position = target.position

