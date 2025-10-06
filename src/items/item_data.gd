class_name ItemData
extends Resource

@export_group("Basic Item Properties")
@export var display_name: String = "Item"
@export var shininess: float = 0.0
@export_multiline var description: String = "A super cool item."
@export var ui_sprite: Texture2D = null
@export var world_scene: PackedScene = null
@export var exclusive_spawn: bool = false

@export_group("Container Properties")
@export var is_container: bool = false
@export_range(1, 25) var capacity: int = 1
@export var ui_scene: PackedScene = null
@export var items: Array[ItemData] = []


func add_item(item: ItemData) -> bool:
	if not is_container:
		push_warning("Tried to add item to non-container.")
		return false

	if items.size() >= capacity:
		return false

	items.append(item)
	return true


func remove_item(item: ItemData) -> bool:
	if not is_container:
		push_warning("Tried to remove item from non-container.")
		return false

	if item not in items:
		return false

	items.erase(item)
	return true
