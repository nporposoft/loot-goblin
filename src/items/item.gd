class_name Item
extends RigidBody2D

@export var item_data: ItemData = null

var _is_open: bool = false
var _container_ui: Control = null


func pickup() -> ItemData:
	var data = item_data
	call_deferred("queue_free")
	return data


func add_item(item: ItemData) -> bool:
	if not item_data.is_container:
		push_warning("Tried to add item to non-container item.")
		return false

	if item_data.items.size() >= item_data.container_capacity:
		return false

	item_data.items.append(item)
	return true


func remove_item(item: ItemData) -> bool:
	if not item_data.is_container:
		push_warning("Tried to remove item from non-container item.")
		return false

	if item not in item_data.items:
		return false

	item_data.items.erase(item)
	return true


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
	_container_ui.position = position
	_container_ui.setup(controller, self)
	_container_ui.on_close.connect(close_container)
	get_tree().current_scene.add_child(_container_ui)
	_is_open = true


func close_container() -> void:
	if _container_ui != null and is_instance_valid(_container_ui):
		_container_ui.queue_free()
		_container_ui = null
		_is_open = false
