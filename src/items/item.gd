class_name Item
extends RigidBody2D

@export var item_data: ItemData = null

var _is_open: bool = false
var _container_ui: Control = null


func pickup() -> ItemData:
	var data = item_data
	call_deferred("queue_free")
	return data


func interact(controller: PlayerCharacterController) -> void:
	if item_data.is_container:
		if _is_open:
			close_container()
		else:
			open_container(controller)


func open_container(controller: PlayerCharacterController) -> void:
	if !item_data.is_container: return

	if _is_open: return

	if item_data.ui_scene == null:
		push_error("Container item has no UI scene assigned.")
		return

	_container_ui = item_data.ui_scene.instantiate()
	_container_ui.set_position(position)
	_container_ui.setup(controller, self)
	get_tree().current_scene.add_child(_container_ui)
	_is_open = true


func close_container() -> void:
	if _container_ui != null and is_instance_valid(_container_ui):
		_container_ui.queue_free()
		_container_ui = null
		_is_open = false


func destroy() -> void:
	queue_free()
