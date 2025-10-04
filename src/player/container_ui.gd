class_name ContainerUI
extends Control

var _controller: PlayerCharacterController = null
var _container: Item = null
var _container_data: ItemData = null

@onready var _slots: Array[ContainerUISlot] = _get_slots()


func setup(controller: PlayerCharacterController, container: Item) -> void:
	_controller = controller
	_container = container
	_container_data = container.item_data


func _ready() -> void:
	_set_slot_items()
	if _container_data.capacity != _slots.size(): push_warning("Container UI _slots do not match container capacity.")


func _on_select(slot: ContainerUISlot) -> void:
	var new_item = _controller.character.remove_item()
	var old_item = slot.set_item(new_item)
	_container_data.remove_item(old_item)
	_container_data.add_item(new_item)
	_controller.character.hold_item(old_item)


func _set_slot_items() -> void:
	for i in range(_container_data.items.size()):
		if i >= _slots.size(): break

		var item: ItemData = _container_data.items[i]
		_slots[i].set_item(item)


func _get_slots() -> Array[ContainerUISlot]:
	var slots: Array[ContainerUISlot] = []
	for slot in get_children():
		if slot is ContainerUISlot:
			slot.on_selected.connect(_on_select)
			slots.append(slot)
	return slots
