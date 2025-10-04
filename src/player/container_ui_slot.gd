class_name ContainerUISlot
extends TextureButton

signal on_selected(slot: ContainerUISlot)

var _item: ItemData = null

@onready var _item_icon: TextureRect = $Item


func _pressed() -> void:
	on_selected.emit(self)


# Sets the _item in this slot. Returns the old _item if there was one.
func set_item(new_item: ItemData) -> ItemData:
	# remove item
	if _item != null and new_item == null:
		var old_item = _item
		_item = null
		_update_icon()
		return old_item

	# place item in empty slot
	if _item == null and new_item != null:
		_item = new_item
		_update_icon()
		return null

	# replace item
	if _item != null and new_item != null:
		var old_item = _item
		_item = new_item
		_update_icon()
		return old_item

	return null


func _update_icon() -> void:
	if _item == null:
		_item_icon.texture = null
		_item_icon.visible = false
	else:
		_item_icon.texture = _item.ui_sprite
		_item_icon.visible = true

