class_name Terrain
extends TileMapLayer

signal on_finished_generating

var source_id: int = 0
var width: int = 58
var height: int = 32

@export var RAND_FLOOR_FRACTION: float = 2.0/3.0
@export var ROOM_QTY_MIN: int = 8
@export var ROOM_QTY_RANGE: int = 10
@export var WORLD_RADIUS: int = 50
@export var ROOM_DIM_MIN: int = 5
@export var ROOM_DIM_RANGE: int = 10
@export var BOX_ROOMS_QTY: int = 60
@export var MAX_CATACOMBS_ROOMS: int = 250

# Small tiles atlas coordinates: 
const wallAtlas: Vector2i = Vector2i(3, 0)
const floorAtlas: Vector2i = Vector2i(3, 2)
const fancyFloorAtlas: Vector2i = Vector2i(0, 0)
# Catacomb rooms atlas coordinates:
const emptyAtlas: Vector2i = Vector2i(-1, -1)
const crossAtlas: Vector2i = Vector2i(0, 2)
const cross_Block_Atlas: Vector2i = Vector2i(0, 3)
const deadEnd_S_Atlas: Vector2i = Vector2i(1, 0)
const deadEnd_W_Atlas: Vector2i = Vector2i(1, 1)
const deadEnd_N_Atlas: Vector2i = Vector2i(1, 2)
const deadEnd_E_Atlas: Vector2i = Vector2i(1, 3)
const corner_NE_Atlas: Vector2i = Vector2i(2, 0)
const corner_SE_Atlas: Vector2i = Vector2i(2, 1)
const corner_SW_Atlas: Vector2i = Vector2i(2, 2)
const corner_NW_Atlas: Vector2i = Vector2i(2, 3)
const tee_NSW_Atlas: Vector2i = Vector2i(3, 0)
const tee_NWE_Atlas: Vector2i = Vector2i(3, 1)
const tee_NES_Atlas: Vector2i = Vector2i(3, 2)
const tee_ESW_Atlas: Vector2i = Vector2i(3, 3)
const hall_NS_Atlas: Vector2i = Vector2i(4, 0)
const hall_EW_Atlas: Vector2i = Vector2i(4, 1)
const deadEnd_BlockS_Atlas: Vector2i = Vector2i(4, 2)
const deadEnd_BlockN_Atlas: Vector2i = Vector2i(4, 0)

enum Path {CLOSED, ANY, OPEN}

func _ready():
	#generate_random_world()		# works bad
	#generate_dungeon_world()	# works worse
	#generate_box_world()		# kinda works, but still sucks
	generate_catacombs()
	on_finished_generating.emit()


func generate_catacombs() -> void:
	var roomsToGen: Array = [Vector2i(1, 1), Vector2i(0, 2), Vector2i(-1, 1)]
	var validAtlasCoords: Array
	var roomsLeft:int = MAX_CATACOMBS_ROOMS
	
	while roomsToGen.size() > 0 and roomsLeft > 0:
		var currentRoom: Vector2i = roomsToGen.pop_front()
		var currentPaths: Array = findPaths(currentRoom)
		validAtlasCoords = [crossAtlas, cross_Block_Atlas, deadEnd_S_Atlas, deadEnd_W_Atlas,
			deadEnd_N_Atlas, deadEnd_E_Atlas, corner_NE_Atlas, corner_SE_Atlas,
			corner_SW_Atlas, corner_NW_Atlas, tee_NSW_Atlas, tee_NWE_Atlas,
			tee_NES_Atlas, tee_ESW_Atlas, hall_NS_Atlas, hall_EW_Atlas,
			deadEnd_BlockS_Atlas, deadEnd_BlockN_Atlas]
		
		# Check Eastern neighbor:
		if currentPaths[0] != Path.ANY:			# Empty: no rooms eliminated 
			if currentPaths[0] == Path.CLOSED:	# No W door in E neighbor: remove all w/ E doors
				validAtlasCoords.erase(crossAtlas)
				validAtlasCoords.erase(cross_Block_Atlas)
				validAtlasCoords.erase(deadEnd_E_Atlas)
				validAtlasCoords.erase(corner_NE_Atlas)
				validAtlasCoords.erase(corner_SE_Atlas)
				validAtlasCoords.erase(tee_NWE_Atlas)
				validAtlasCoords.erase(tee_NES_Atlas)
				validAtlasCoords.erase(tee_ESW_Atlas)
				validAtlasCoords.erase(hall_EW_Atlas)
			else:								# W door exists in E neighbor: remove all w/o E doors
				validAtlasCoords.erase(deadEnd_S_Atlas)
				validAtlasCoords.erase(deadEnd_W_Atlas)
				validAtlasCoords.erase(deadEnd_N_Atlas)
				validAtlasCoords.erase(corner_SW_Atlas)
				validAtlasCoords.erase(corner_NW_Atlas)
				validAtlasCoords.erase(tee_NSW_Atlas)
				validAtlasCoords.erase(hall_NS_Atlas)
				validAtlasCoords.erase(deadEnd_BlockS_Atlas)
				validAtlasCoords.erase(deadEnd_BlockN_Atlas)
		# Check Northern neighbor:
		if currentPaths[1] != Path.ANY:			# Empty: no rooms eliminated
			if currentPaths[1] == Path.CLOSED:	# No S door in N neighbor: remove all w/ N doors
				validAtlasCoords.erase(crossAtlas)
				validAtlasCoords.erase(cross_Block_Atlas)
				validAtlasCoords.erase(deadEnd_N_Atlas)
				validAtlasCoords.erase(corner_NE_Atlas)
				validAtlasCoords.erase(corner_NW_Atlas)
				validAtlasCoords.erase(tee_NSW_Atlas)
				validAtlasCoords.erase(tee_NWE_Atlas)
				validAtlasCoords.erase(tee_NES_Atlas)
				validAtlasCoords.erase(hall_NS_Atlas)
				validAtlasCoords.erase(deadEnd_BlockN_Atlas)
			else:								# S door exists in N neighbor: remove all w/o N doors
				validAtlasCoords.erase(deadEnd_S_Atlas)
				validAtlasCoords.erase(deadEnd_W_Atlas)
				validAtlasCoords.erase(deadEnd_E_Atlas)
				validAtlasCoords.erase(corner_SE_Atlas)
				validAtlasCoords.erase(corner_SW_Atlas)
				validAtlasCoords.erase(tee_ESW_Atlas)
				validAtlasCoords.erase(hall_EW_Atlas)
				validAtlasCoords.erase(deadEnd_BlockS_Atlas)
		# Check Western neighbor:
		if currentPaths[2] != Path.ANY:			# Empty: no rooms eliminated
			if currentPaths[2] == Path.CLOSED:	# No E door in W neighbor: remove all w/ W doors
				validAtlasCoords.erase(crossAtlas)
				validAtlasCoords.erase(cross_Block_Atlas)
				validAtlasCoords.erase(deadEnd_W_Atlas)
				validAtlasCoords.erase(corner_SW_Atlas)
				validAtlasCoords.erase(corner_NW_Atlas)
				validAtlasCoords.erase(tee_NSW_Atlas)
				validAtlasCoords.erase(tee_NWE_Atlas)
				validAtlasCoords.erase(tee_ESW_Atlas)
				validAtlasCoords.erase(hall_EW_Atlas)
			else:								# E door exists in W neighbor: remove all w/o W doors
				validAtlasCoords.erase(deadEnd_S_Atlas)
				validAtlasCoords.erase(deadEnd_N_Atlas)
				validAtlasCoords.erase(deadEnd_E_Atlas)
				validAtlasCoords.erase(corner_NE_Atlas)
				validAtlasCoords.erase(corner_SE_Atlas)
				validAtlasCoords.erase(tee_NES_Atlas)
				validAtlasCoords.erase(hall_NS_Atlas)
				validAtlasCoords.erase(deadEnd_BlockS_Atlas)
				validAtlasCoords.erase(deadEnd_BlockN_Atlas)
		# Check Southern neighbor:
		if currentPaths[3] != Path.ANY:			# Empty: no rooms eliminated
			if currentPaths[3] == Path.CLOSED:	# No N door in S neighbor: remove all w/ S doors
				validAtlasCoords.erase(crossAtlas)
				validAtlasCoords.erase(cross_Block_Atlas)
				validAtlasCoords.erase(deadEnd_S_Atlas)
				validAtlasCoords.erase(corner_SE_Atlas)
				validAtlasCoords.erase(corner_SW_Atlas)
				validAtlasCoords.erase(tee_NSW_Atlas)
				validAtlasCoords.erase(tee_NES_Atlas)
				validAtlasCoords.erase(tee_ESW_Atlas)
				validAtlasCoords.erase(hall_NS_Atlas)
				validAtlasCoords.erase(deadEnd_BlockS_Atlas)
			else:								# N door exists in S neighbor: remove all w/o S doors
				validAtlasCoords.erase(deadEnd_W_Atlas)
				validAtlasCoords.erase(deadEnd_N_Atlas)
				validAtlasCoords.erase(deadEnd_E_Atlas)
				validAtlasCoords.erase(corner_NE_Atlas)
				validAtlasCoords.erase(corner_NW_Atlas)
				validAtlasCoords.erase(tee_NWE_Atlas)
				validAtlasCoords.erase(hall_EW_Atlas)
				validAtlasCoords.erase(deadEnd_BlockN_Atlas)
				
				# ALL POSSIBLE ROOMS:
				#validAtlasCoords.erase(crossAtlas)
				#validAtlasCoords.erase(cross_Block_Atlas)
				#validAtlasCoords.erase(deadEnd_S_Atlas)
				#validAtlasCoords.erase(deadEnd_W_Atlas)
				#validAtlasCoords.erase(deadEnd_N_Atlas)
				#validAtlasCoords.erase(deadEnd_E_Atlas)
				#validAtlasCoords.erase(corner_NE_Atlas)
				#validAtlasCoords.erase(corner_SE_Atlas)
				#validAtlasCoords.erase(corner_SW_Atlas)
				#validAtlasCoords.erase(corner_NW_Atlas)
				#validAtlasCoords.erase(tee_NSW_Atlas)
				#validAtlasCoords.erase(tee_NWE_Atlas)
				#validAtlasCoords.erase(tee_NES_Atlas)
				#validAtlasCoords.erase(tee_ESW_Atlas)
				#validAtlasCoords.erase(hall_NS_Atlas)
				#validAtlasCoords.erase(hall_EW_Atlas)
				#validAtlasCoords.erase(deadEnd_BlockS_Atlas)
				#validAtlasCoords.erase(deadEnd_BlockN_Atlas)
		var roomChoice: Vector2i
		if validAtlasCoords.size() > 0:
			roomChoice = validAtlasCoords[randi() % validAtlasCoords.size()]
		else:
			roomChoice = crossAtlas
		set_cell(currentRoom, 1, roomChoice)
		
		var roomsToStack: Array = get_rooms_to_stack(currentRoom)
		for r in roomsToStack:
			roomsToGen.push_back(r)
		
		roomsLeft = roomsLeft - 1

func get_rooms_to_stack(newRoom: Vector2i) -> Array:
	var outputArray: Array
	var paths: Array = findPaths(newRoom)
	if [crossAtlas, cross_Block_Atlas, deadEnd_E_Atlas, corner_NE_Atlas,
		corner_SE_Atlas, tee_NWE_Atlas, tee_NES_Atlas, tee_ESW_Atlas,
		hall_EW_Atlas].has(get_cell_atlas_coords(newRoom)): # if newroom has E door
			outputArray.push_back(Vector2i(newRoom.x+1,newRoom.y)) # stack room to be gen'd E
	if [crossAtlas, cross_Block_Atlas, deadEnd_N_Atlas, corner_NE_Atlas,
		corner_NW_Atlas, tee_NSW_Atlas, tee_NWE_Atlas, tee_NES_Atlas,
		hall_NS_Atlas, deadEnd_BlockN_Atlas].has(get_cell_atlas_coords(newRoom)): # if newroom has N door
			outputArray.push_back(Vector2i(newRoom.x,newRoom.y-1)) # stack room to be gen'd N
	if [crossAtlas, cross_Block_Atlas, deadEnd_W_Atlas, corner_SW_Atlas,
		corner_NW_Atlas, tee_NSW_Atlas, tee_NWE_Atlas, tee_ESW_Atlas,
		hall_EW_Atlas].has(get_cell_atlas_coords(newRoom)): # if newroom has W door
			outputArray.push_back(Vector2i(newRoom.x-1,newRoom.y)) # stack room to be gen'd W
	if [crossAtlas, cross_Block_Atlas, deadEnd_S_Atlas, corner_SE_Atlas,
		corner_SW_Atlas, tee_NSW_Atlas, tee_NES_Atlas, tee_ESW_Atlas,
		hall_NS_Atlas, deadEnd_BlockS_Atlas].has(get_cell_atlas_coords(newRoom)): # if newroom has S door
			outputArray.push_back(Vector2i(newRoom.x,newRoom.y+1)) # stack room to be gen'd S
		
	return outputArray

func findPaths(room: Vector2i) -> Array:
	var outputArray: Array
	var currentNeighbor: Vector2i
	var openNeighbors: Array
	
	# Get status of East neighbor:
	currentNeighbor = Vector2i(room.x+1, room.y)
	if get_cell_atlas_coords(currentNeighbor) == emptyAtlas:
		outputArray.push_back(Path.ANY)
	else:
		openNeighbors = [crossAtlas, cross_Block_Atlas, deadEnd_W_Atlas, corner_SW_Atlas,
			corner_NW_Atlas, tee_NSW_Atlas, tee_NWE_Atlas, tee_ESW_Atlas,
			hall_EW_Atlas] # atlas coords with W facing doors
		if openNeighbors.has(currentNeighbor):
			outputArray.push_back(Path.OPEN)
		else:
			outputArray.push_back(Path.CLOSED)
	
	# Get status of North neighbor:
	currentNeighbor = Vector2i(room.x, room.y-1)
	if get_cell_atlas_coords(currentNeighbor) == emptyAtlas:
		outputArray.push_back(Path.ANY)
	else:
		openNeighbors = [crossAtlas, cross_Block_Atlas, deadEnd_S_Atlas, corner_SE_Atlas,
			corner_SW_Atlas, tee_NSW_Atlas, tee_NES_Atlas, tee_ESW_Atlas,
			hall_NS_Atlas, deadEnd_BlockS_Atlas] # atlas coords with S facing doors
		if openNeighbors.has(currentNeighbor):
			outputArray.push_back(Path.OPEN)
		else:
			outputArray.push_back(Path.CLOSED)
	
	# Get status of West neighbor:
	currentNeighbor = Vector2i(room.x-1, room.y)
	if get_cell_atlas_coords(currentNeighbor) == emptyAtlas:
		outputArray.push_back(Path.ANY)
	else:
		openNeighbors = [crossAtlas, cross_Block_Atlas, deadEnd_E_Atlas, corner_NE_Atlas,
			corner_SE_Atlas, tee_NWE_Atlas, tee_NES_Atlas, tee_ESW_Atlas,
			hall_EW_Atlas] # atlas coords with E facing doors
		if openNeighbors.has(currentNeighbor):
			outputArray.push_back(Path.OPEN)
		else:
			outputArray.push_back(Path.CLOSED)
	
	# Get status of South neighbor:
	currentNeighbor = Vector2i(room.x, room.y+1)
	if get_cell_atlas_coords(currentNeighbor) == emptyAtlas:
		outputArray.push_back(Path.ANY)
	else:
		openNeighbors = [crossAtlas, cross_Block_Atlas, deadEnd_N_Atlas, corner_NE_Atlas,
			corner_NW_Atlas, tee_NSW_Atlas, tee_NWE_Atlas, tee_NES_Atlas,
			hall_NS_Atlas, deadEnd_BlockN_Atlas] # atlas coords with N facing doors
		if openNeighbors.has(currentNeighbor):
			outputArray.push_back(Path.OPEN)
		else:
			outputArray.push_back(Path.CLOSED)
	
	return outputArray


func generate_box_world() -> void:
	place_box_rooms(BOX_ROOMS_QTY)
	draw_doors(10)
	set_cell(Vector2i(0, 6), 0, floorAtlas)
	set_cell(Vector2i(0, 7), 0, floorAtlas)
	set_cell(Vector2i(0, 8), 0, floorAtlas)
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
				set_cell(Vector2i(i + footprint.position.x,j + footprint.position.y), 0, floorAtlas)
		for i in range(footprint.size.x + 2):
			set_cell(Vector2i(footprint.position.x - 1 + i,footprint.position.y - 1), 0, wallAtlas)
			set_cell(Vector2i(footprint.position.x - 1 + i,footprint.position.y + footprint.size.y), 0, wallAtlas)
		var j1: int = 1 + randi() % int(footprint.size.y)
		var j2: int = 1 + randi() % int(footprint.size.y)
		for j in range(footprint.size.y):
			if j == j1:
				set_cell(Vector2i(footprint.position.x - 1, footprint.position.y + j), 0, floorAtlas)
			else:
				set_cell(Vector2i(footprint.position.x - 1, footprint.position.y + j), 0, wallAtlas) 
			if j == j2:
				set_cell(Vector2i(footprint.position.x + footprint.size.x, footprint.position.y + j), 0, floorAtlas)
			else:
				set_cell(Vector2i(footprint.position.x + footprint.size.x, footprint.position.y + j), 0, wallAtlas)


func draw_doors(numDoors: int) -> void:
	#var line: Rect2
	#for n in range(numDoors):
		#if randi() % 2 == 0:
			#line = Rect2(randi() % (WORLD_RADIUS * 2) - WORLD_RADIUS, randi() % (WORLD_RADIUS * 2) - WORLD_RADIUS, 1, 3 + randi() % 5)
		#else:
			#line = Rect2(randi() % (WORLD_RADIUS * 2) - WORLD_RADIUS, randi() % (WORLD_RADIUS * 2) - WORLD_RADIUS, 3 + randi() % 5, 1)
		#for i in range(line.size.x):
			#for j in range(line.size.y):
				#set_cell(Vector2i(line.position.x + i, line.position.y + j), 0, floorAtlas)
	for i in range(-WORLD_RADIUS + WORLD_RADIUS * 2):
		for j in range(-WORLD_RADIUS + WORLD_RADIUS * 2):
			var t: TileData = get_cell_tile_data(Vector2i(i,j))
			if t.get_collision_polygons_count(0) > 0:
				var neighborArray: Array = get_surrounding_cells(Vector2i(i,j))


func generate_dungeon_world() -> void:
	var start: Vector2i = Vector2i(0, 5)
	
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
					if get_cell_tile_data(Vector2i(i + footprint.position.x,j + footprint.position.y)):
						footprintClear = false
						break
				if not footprintClear:
					break
		for i in range(footprint.size.x):
			for j in range(footprint.size.y):
				set_cell(Vector2i(i + footprint.position.x,j + footprint.position.y), 0, floorAtlas)
		roomArray.push_back(footprint)
	return roomArray


func connect_rooms(startTile: Vector2i, roomArray: Array) -> void:
	var tempRooms: Array = roomArray
	var nextRoom: Rect2
	var beginPoint: Vector2i = startTile
	
	while tempRooms.size() > 0:
		nextRoom = tempRooms.pop_front()
		beginPoint = tunnel(beginPoint, nextRoom)


func tunnel(startPoint: Vector2i, destination: Rect2) -> Vector2i:
	var primaryDirection: Vector2i
	var secondaryDirection: Vector2i
	var xDistance: int = get_x_dist(startPoint, destination)
	var yDistance: int = get_y_dist(startPoint, destination)
	if abs(xDistance) <= abs(yDistance):
		primaryDirection = Vector2i(float(xDistance), 0.0)
		secondaryDirection = Vector2i(0.0, float(yDistance))
	else:
		primaryDirection = Vector2i(0.0, float(yDistance))
		secondaryDirection = Vector2i(float(xDistance), 0.0)
	
	var currentTile: Vector2i = startPoint
	var nextTile: Vector2i
	
	var tunneling: bool = true
	var safetyTimeout: int = 1000
	while tunneling and safetyTimeout > 0:
		safetyTimeout = safetyTimeout - 1
		nextTile = currentTile + primaryDirection
		match primaryDirection:
			Vector2i.RIGHT:
				if (currentTile.x >= destination.position.x and randf() < (currentTile.x - destination.position.x) / destination.size.x) or currentTile.x >= destination.position.x + destination.size.x:
					var third: Vector2i = primaryDirection # extra space to swap primary and secondary 
					primaryDirection = secondaryDirection
					secondaryDirection = third
			Vector2i.UP:
				if (currentTile.y <= destination.position.y + destination.size.y and randf() < (currentTile.y - destination.position.y + destination.size.y) / destination.position.y) or currentTile.y <= destination.position.y:
					var third: Vector2i = primaryDirection # extra space to swap primary and secondary 
					primaryDirection = secondaryDirection
					secondaryDirection = third
			Vector2i.LEFT:
				if (currentTile.x <= destination.position.x + destination.size.x and randf() < (currentTile.x - destination.position.x + destination.size.x) / destination.position.x) or currentTile.x <= destination.position.x:
					var third: Vector2i = primaryDirection # extra space to swap primary and secondary 
					primaryDirection = secondaryDirection
					secondaryDirection = third
			Vector2i.DOWN:
				if (currentTile.y >= destination.position.y and randf() < (currentTile.y - destination.position.y) / destination.size.y) or currentTile.y >= destination.position.y + destination.size.y:
					var third: Vector2i = primaryDirection # extra space to swap primary and secondary 
					primaryDirection = secondaryDirection
					secondaryDirection = third
		if point_is_in_rect(nextTile, destination):
			return nextTile
		if not get_cell_tile_data(nextTile):
			set_cell(nextTile, 0, floorAtlas)
			currentTile = currentTile + primaryDirection 
		else:
			var third: Vector2i = primaryDirection # extra space to swap primary and secondary 
			primaryDirection = secondaryDirection
			secondaryDirection = third
			nextTile = currentTile + primaryDirection
			if not get_cell_tile_data(nextTile):
				set_cell(nextTile, 0, floorAtlas)
				currentTile = nextTile
			else:
				tunneling = false
	return startPoint


func point_is_in_rect(point: Vector2i, rect: Rect2) -> bool:
	if point.x >= rect.position.x and point.x <= rect.position.x + rect.size.x and point.y >= rect.position.y and point.y <= rect.position.y + rect.size.y:
		return true
	return false


func get_y_dist(point: Vector2i, rect: Rect2) -> bool:
	if point.x >= rect.position.x and point.x <= rect.position.x + rect.size.x:
		return 0
	if point.x < rect.position.x:
		return point.x - rect.position.x
	return point.x - (rect.position.x + rect.size.x)


func get_x_dist(point: Vector2i, rect: Rect2) -> bool:
	if point.y >= rect.position.y and point.y <= rect.position.y + rect.size.y:
		return 0
	if point.y < rect.position.y:
		return point.y - rect.position.y
	return point.y - (rect.position.y + rect.size.y)


func generate_random_world() -> void:
	for i in range(width):
		for j in range(height):
			if not(get_cell_tile_data(Vector2i(i,j))):
				if i == 0 or j == 0 or i == width-1 or j == height-1:
					set_cell(Vector2i(i, j), 0, wallAtlas)
				elif randf() <= RAND_FLOOR_FRACTION:
					set_cell(Vector2i(i, j), 0, floorAtlas)
	build_walls()


func build_walls() -> void:
	for i in range(width):
		for j in range(height):
			if not(get_cell_tile_data(Vector2i(i,j))):
				var E = get_cell_tile_data(Vector2i(i+1,j))
				var N = get_cell_tile_data(Vector2i(i,j-1))
				var W = get_cell_tile_data(Vector2i(i-1,j))
				var S = get_cell_tile_data(Vector2i(i,j+1))
				if E or N or W or S:
					set_cell(Vector2i(i, j), 0, wallAtlas)
