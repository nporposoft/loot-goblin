class_name Interactable
extends Area2D

signal on_interact(controller: PlayerCharacterController)


func interact(controller: PlayerCharacterController) -> void:
	on_interact.emit(controller)

