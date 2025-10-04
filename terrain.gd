extends TileMapLayer

var source_id: int = 0
var width: int = 58
var height: int = 32
var wallAtlas: Vector2 = Vector2(3, 0)
var floorAtlas: Vector2 = Vector2(3, 2)
var fancyFloorAtlas: Vector2 = Vector2(0, 0)

const FLOOR_FRACTION = 2.0/3.0

func _ready():
	generate_world()

func generate_world() -> void:
	for i in range(width):
		for j in range(height):
			if not(get_cell_tile_data(Vector2(i,j))):
				if i == 0 or j == 0 or i == width-1 or j == height-1:
					set_cell(Vector2(i, j), 0, wallAtlas)
				elif randf() <= FLOOR_FRACTION:
					set_cell(Vector2(i, j), 0, floorAtlas)
	
	for i in range(width):
		for j in range(height):
			if not(get_cell_tile_data(Vector2(i,j))):
				var E = get_cell_tile_data(Vector2(i+1,j))
				var N = get_cell_tile_data(Vector2(i,j-1))
				var W = get_cell_tile_data(Vector2(i-1,j))
				var S = get_cell_tile_data(Vector2(i,j+1))
				if E or N or W or S:
					set_cell(Vector2(i, j), 0, wallAtlas)
	
	#for i in range(0):
		#for j in range(0):
			#set_cell(Vector2(round(i + width/2.0), round(j + height/2.0)), 0, fancyFloorAtlas)
