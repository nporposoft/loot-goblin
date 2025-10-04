extends TileMapLayer

var source_id: int = 0
var width: int = 58
var height: int = 32
var wallAtlas: Vector2 = Vector2(3, 0)
var floorAtlas: Vector2 = Vector2(3, 2)
var fancyFloorAtlas: Vector2 = Vector2(0, 0)

@export var RAND_FLOOR_FRACTION: float = 2.0/3.0
@export var ROOM_QTY_MIN: int = 8
@export var ROOM_QTY_RANGE: int = 10
@export var WORLD_RADIUS: int = 50
@export var ROOM_DIM_MIN: int = 5
@export var ROOM_DIM_RANGE: int = 10
@export var BOX_ROOMS_QTY: int = 60

func _ready():
	#generate_random_world()		# works bad
	#generate_dungeon_world()	# works worse
	#generate_box_world()		# kinda works, but still sucks
	generate_catacombs()

func generate_catacombs() -> void:
	pass

func generate_box_world() -> void:
	place_box_rooms(BOX_ROOMS_QTY)
	draw_doors(10)
	set_cell(Vector2(0, 6), 0, floorAtlas)
	set_cell(Vector2(0, 7), 0, floorAtlas)
	set_cell(Vector2(0, 8), 0, floorAtlas)
	build_walls()

func place_box_rooms(numRooms: int) -> void:
	#var roomArray: Array
	for n in numRooms:
		var footprintClear: bool = false
		var footprint: Rect2
		while not footprintClear:
			footprintClear = true
			var newX: int = (randi() % (WORLD_RADIUS * 2)) - WORLD_RADIUS
			var newY: int = (randi() % (WORLD_RADIUS * 2)) - WORLD_RADIUS
			var newW: int = (randi() % ROOM_DIM_RANGE) + ROOM_DIM_MIN
			var newH: int = (randi() % ROOM_DIM_RANGE) + ROOM_DIM_MIN
			footprint = Rect2(newX, newY, newW, newH)
			if not (footprint.position.x > 6 or footprint.position.y > 6 or footprint.position.x + footprint.size.x < -6 or footprint.position.y + footprint.size.y < -6):
				footprintClear = false
		for i in range(footprint.size.x):
			for j in range(footprint.size.y):
				set_cell(Vector2(i + footprint.position.x,j + footprint.position.y), 0, floorAtlas)
		for i in range(footprint.size.x + 2):
			set_cell(Vector2(footprint.position.x - 1 + i,footprint.position.y - 1), 0, wallAtlas)
			set_cell(Vector2(footprint.position.x - 1 + i,footprint.position.y + footprint.size.y), 0, wallAtlas)
		var j1: int = 1 + randi() % int(footprint.size.y)
		var j2: int = 1 + randi() % int(footprint.size.y)
		for j in range(footprint.size.y):
			if j == j1:
				set_cell(Vector2(footprint.position.x - 1, footprint.position.y + j), 0, floorAtlas)
			else:
				set_cell(Vector2(footprint.position.x - 1, footprint.position.y + j), 0, wallAtlas) 
			if j == j2:
				set_cell(Vector2(footprint.position.x + footprint.size.x, footprint.position.y + j), 0, floorAtlas)
			else:
				set_cell(Vector2(footprint.position.x + footprint.size.x, footprint.position.y + j), 0, wallAtlas)

func draw_doors(numDoors: int) -> void:
	#var line: Rect2
	#for n in range(numDoors):
		#if randi() % 2 == 0:
			#line = Rect2(randi() % (WORLD_RADIUS * 2) - WORLD_RADIUS, randi() % (WORLD_RADIUS * 2) - WORLD_RADIUS, 1, 3 + randi() % 5)
		#else:
			#line = Rect2(randi() % (WORLD_RADIUS * 2) - WORLD_RADIUS, randi() % (WORLD_RADIUS * 2) - WORLD_RADIUS, 3 + randi() % 5, 1)
		#for i in range(line.size.x):
			#for j in range(line.size.y):
				#set_cell(Vector2(line.position.x + i, line.position.y + j), 0, floorAtlas)
	for i in range(-WORLD_RADIUS + WORLD_RADIUS * 2):
		for j in range(-WORLD_RADIUS + WORLD_RADIUS * 2):
			var t: TileData = get_cell_tile_data(Vector2(i,j))
			if t.get_collision_polygons_count(0) > 0:
				var neighborArray: Array = get_surrounding_cells(Vector2(i,j))

func generate_dungeon_world() -> void:
	var start: Vector2 = Vector2(0, 5)
	
	var roomQty: int = ROOM_QTY_MIN + randi() % ROOM_QTY_RANGE
	var rooms: Array = place_dungeon_rooms(roomQty)
	
	connect_rooms(start, rooms)
	
	#build_walls()

func place_dungeon_rooms(numRooms: int) -> Array:
	var roomArray: Array
	for n in numRooms:
		var footprintClear: bool = false
		var footprint: Rect2
		while not footprintClear:
			footprintClear = true
			footprint = Rect2(-WORLD_RADIUS + randi() % (WORLD_RADIUS * 2), -WORLD_RADIUS + randi() % (WORLD_RADIUS * 2), ROOM_DIM_MIN + randi() % ROOM_DIM_RANGE, ROOM_DIM_MIN + randi() % ROOM_DIM_RANGE)
			for i in range(footprint.size.x):
				for j in range(footprint.size.y):
					if get_cell_tile_data(Vector2(i + footprint.position.x,j + footprint.position.y)):
						footprintClear = false
						break
				if not footprintClear:
					break
		for i in range(footprint.size.x):
			for j in range(footprint.size.y):
				set_cell(Vector2(i + footprint.position.x,j + footprint.position.y), 0, floorAtlas)
		roomArray.push_back(footprint)
	return roomArray

func connect_rooms(startTile: Vector2, roomArray: Array) -> void:
	var tempRooms: Array = roomArray
	var nextRoom: Rect2
	var beginPoint: Vector2 = startTile
	
	while tempRooms.size() > 0:
		nextRoom = tempRooms.pop_front()
		beginPoint = tunnel(beginPoint, nextRoom)

func tunnel(startPoint: Vector2, destination: Rect2) -> Vector2:
	var primaryDirection: Vector2
	var secondaryDirection: Vector2
	var xDistance: int = get_x_dist(startPoint, destination)
	var yDistance: int = get_y_dist(startPoint, destination)
	if abs(xDistance) <= abs(yDistance):
		primaryDirection = Vector2(float(xDistance), 0.0).normalized()
		secondaryDirection = Vector2(0.0, float(yDistance)).normalized()
	else:
		primaryDirection = Vector2(0.0, float(yDistance)).normalized()
		secondaryDirection = Vector2(float(xDistance), 0.0).normalized()
	
	var currentTile: Vector2 = startPoint
	var nextTile: Vector2
	
	var tunneling: bool = true
	var safetyTimeout: int = 1000
	while tunneling and safetyTimeout > 0:
		safetyTimeout = safetyTimeout - 1
		nextTile = currentTile + primaryDirection
		match primaryDirection:
			Vector2.RIGHT:
				if (currentTile.x >= destination.position.x and randf() < (currentTile.x - destination.position.x) / destination.size.x) or currentTile.x >= destination.position.x + destination.size.x:
					var third: Vector2 = primaryDirection # extra space to swap primary and secondary 
					primaryDirection = secondaryDirection
					secondaryDirection = third
			Vector2.UP:
				if (currentTile.y <= destination.position.y + destination.size.y and randf() < (currentTile.y - destination.position.y + destination.size.y) / destination.position.y) or currentTile.y <= destination.position.y:
					var third: Vector2 = primaryDirection # extra space to swap primary and secondary 
					primaryDirection = secondaryDirection
					secondaryDirection = third
			Vector2.LEFT:
				if (currentTile.x <= destination.position.x + destination.size.x and randf() < (currentTile.x - destination.position.x + destination.size.x) / destination.position.x) or currentTile.x <= destination.position.x:
					var third: Vector2 = primaryDirection # extra space to swap primary and secondary 
					primaryDirection = secondaryDirection
					secondaryDirection = third
			Vector2.DOWN:
				if (currentTile.y >= destination.position.y and randf() < (currentTile.y - destination.position.y) / destination.size.y) or currentTile.y >= destination.position.y + destination.size.y:
					var third: Vector2 = primaryDirection # extra space to swap primary and secondary 
					primaryDirection = secondaryDirection
					secondaryDirection = third
		if point_is_in_rect(nextTile, destination):
			return nextTile
		if not get_cell_tile_data(nextTile):
			set_cell(nextTile, 0, floorAtlas)
			currentTile = currentTile + primaryDirection 
		else:
			var third: Vector2 = primaryDirection # extra space to swap primary and secondary 
			primaryDirection = secondaryDirection
			secondaryDirection = third
			nextTile = currentTile + primaryDirection
			if not get_cell_tile_data(nextTile):
				set_cell(nextTile, 0, floorAtlas)
				currentTile = nextTile
			else:
				tunneling = false
	return startPoint

func point_is_in_rect(point: Vector2, rect: Rect2) -> bool:
	if point.x >= rect.position.x and point.x <= rect.position.x + rect.size.x and point.y >= rect.position.y and point.y <= rect.position.y + rect.size.y:
		return true
	return false

func get_y_dist(point: Vector2, rect: Rect2) -> bool:
	if point.x >= rect.position.x and point.x <= rect.position.x + rect.size.x:
		return 0
	if point.x < rect.position.x:
		return point.x - rect.position.x
	return point.x - (rect.position.x + rect.size.x)

func get_x_dist(point: Vector2, rect: Rect2) -> bool:
	if point.y >= rect.position.y and point.y <= rect.position.y + rect.size.y:
		return 0
	if point.y < rect.position.y:
		return point.y - rect.position.y
	return point.y - (rect.position.y + rect.size.y)

func generate_random_world() -> void:
	for i in range(width):
		for j in range(height):
			if not(get_cell_tile_data(Vector2(i,j))):
				if i == 0 or j == 0 or i == width-1 or j == height-1:
					set_cell(Vector2(i, j), 0, wallAtlas)
				elif randf() <= RAND_FLOOR_FRACTION:
					set_cell(Vector2(i, j), 0, floorAtlas)
	build_walls()

func build_walls() -> void:
	for i in range(width):
		for j in range(height):
			if not(get_cell_tile_data(Vector2(i,j))):
				var E = get_cell_tile_data(Vector2(i+1,j))
				var N = get_cell_tile_data(Vector2(i,j-1))
				var W = get_cell_tile_data(Vector2(i-1,j))
				var S = get_cell_tile_data(Vector2(i,j+1))
				if E or N or W or S:
					set_cell(Vector2(i, j), 0, wallAtlas)
