class_name ItemData
extends Resource

@export_group("Basic Item Properties")
@export var display_name: String = "Item"
@export_multiline var description: String = "A super cool item."
@export var ui_sprite: Texture2D = null
@export var world_scene: PackedScene = null

@export_group("Container Properties")
@export var is_container: bool = false
@export_range(1, 5) var rows: int = 1
@export_range(1, 5) var columns: int = 1
@export var ui_scene: PackedScene = null
@export var items: Array[ItemData] = []

var capacity: int:
	get:
		return rows * columns
