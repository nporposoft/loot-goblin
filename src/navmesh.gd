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
	var map_rect: Rect2 = map.get_used_rect()
	navigation_polygon.add_outline(PackedVector2Array([
		Vector2(map_rect.position.x, map_rect.position.y) * tile_size,
		Vector2(map_rect.end.x, map_rect.position.y) * tile_size,
		Vector2(map_rect.end.x, map_rect.end.y) * tile_size,
		Vector2(map_rect.position.x, map_rect.end.y) * tile_size
	]))
	bake_navigation_polygon()

