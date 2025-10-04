extends RigidBody2D

class_name Item

@export var item_data: ItemData = null

func pickup() -> ItemData:
	var data = item_data
	call_deferred("queue_free")
	return data

