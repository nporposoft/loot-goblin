class_name NavMesh
extends NavigationRegion2D

@export var map: Terrain = null


func _ready():
	if map == null:
		push_error("NavMesh: Terrain map is not assigned.")
		return

	map.on_finished_generating.connect(_bake_nav_mesh)


func _bake_nav_mesh() -> void:
	var tile_size: int = map.tile_set.tile_size.x
	navigation_polygon.add_outline(PackedVector2Array([
		Vector2(0, 0),
		Vector2(map.width * tile_size, 0),
		Vector2(map.width * tile_size, map.height * tile_size),
		Vector2(0, map.height * tile_size)
	]))
	bake_navigation_polygon()

