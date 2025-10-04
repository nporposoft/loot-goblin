class_name ItemSpawnerUtility
extends Node


func spawn_item(item_data: ItemData, position: Vector2, velocity: Vector2 = Vector2.ZERO) -> Item:
	if item_data == null or item_data.world_scene == null:
		push_error("Invalid item data or world scene.")
		return null

	var item_instance = item_data.world_scene.instantiate() as Item
	if item_instance == null:
		push_error("Failed to instantiate item scene.")
		return null

	item_instance.item_data = item_data
	item_instance.position = position
	item_instance.linear_velocity = velocity
	get_tree().current_scene.add_child(item_instance)
	return item_instance
