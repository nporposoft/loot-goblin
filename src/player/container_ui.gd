class_name ContainerUI
extends Control

var _controller: PlayerCharacterController = null
var _container_item: Item = null


func setup(controller: PlayerCharacterController, container_item: Item) -> void:
	_controller = controller
	_container_item = container_item


func _assign_items_to_buttons() -> void:
	pass
