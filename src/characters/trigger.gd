class_name Trigger
extends Area2D

signal on_triggered


func trigger() -> void:
	on_triggered.emit()
