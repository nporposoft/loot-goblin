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
@export var MAX_CATACOMBS_ROOMS: int = 1000

# Small tiles atlas coordinates: 
const wallAtlas: Vector2i = Vector2i(3, 0)
const floorAtlas: Vector2i = Vector2i(3, 2)
const fancyFloorAtlas: Vector2i = Vector2i(0, 0)
# Catacomb rooms atlas coordinates:
const emptyAtlas: Vector2i = Vector2i(-1, -1)
const startRoomAtlas: Vector2i = Vector2i(0, 1)
const crossAtlas: Vector2i = Vector2i(0, 2)
const solidBlock_Atlas: Vector2i = Vector2i(0, 3)
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
const hallBars_NS_Atlas: Vector2i = Vector2i(4, 2)
const hallBars_EW_Atlas: Vector2i = Vector2i(4, 3)

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
	
	var debug_DeadEndRerolls: int = 0
	var debug_HallRerolls: int = 0
	var debug_4WayRerolls: int = 0
	var debug_TeeRerolls: int = 0
	
	while roomsToGen.size() > 0 and roomsLeft > 0:
		var currentRoom: Vector2i = roomsToGen.pop_front()
		if get_cell_atlas_coords(currentRoom) != emptyAtlas:
			continue
		var currentPaths: Array = findPaths(currentRoom)
		validAtlasCoords = [crossAtlas, deadEnd_S_Atlas, deadEnd_W_Atlas,
			deadEnd_N_Atlas, deadEnd_E_Atlas, corner_NE_Atlas, corner_SE_Atlas,
			corner_SW_Atlas, corner_NW_Atlas, tee_NSW_Atlas, tee_NWE_Atlas,
			tee_NES_Atlas, tee_ESW_Atlas, hall_NS_Atlas, hall_EW_Atlas,
			hallBars_NS_Atlas, hallBars_EW_Atlas]
		
		# Check Eastern neighbor:
		if currentPaths[0] != Path.ANY:			# Empty: no rooms eliminated 
			if currentPaths[0] == Path.CLOSED:	# No W door in E neighbor: remove all w/ E doors
				validAtlasCoords.erase(crossAtlas)
				validAtlasCoords.erase(deadEnd_E_Atlas)
				validAtlasCoords.erase(corner_NE_Atlas)
				validAtlasCoords.erase(corner_SE_Atlas)
				validAtlasCoords.erase(tee_NWE_Atlas)
				validAtlasCoords.erase(tee_NES_Atlas)
				validAtlasCoords.erase(tee_ESW_Atlas)
				validAtlasCoords.erase(hall_EW_Atlas)
				#print_debug("E is closed off:", get_cell_atlas_coords(Vector2i(currentRoom.x+1, currentRoom.y)))
			else:								# W door exists in E neighbor: remove all w/o E doors
				validAtlasCoords.erase(deadEnd_S_Atlas)
				validAtlasCoords.erase(deadEnd_W_Atlas)
				validAtlasCoords.erase(deadEnd_N_Atlas)
				validAtlasCoords.erase(corner_SW_Atlas)
				validAtlasCoords.erase(corner_NW_Atlas)
				validAtlasCoords.erase(tee_NSW_Atlas)
				validAtlasCoords.erase(hall_NS_Atlas)
				validAtlasCoords.erase(hallBars_NS_Atlas)
				#print_debug("E is open:", get_cell_atlas_coords(Vector2i(currentRoom.x+1, currentRoom.y)))
		else:
			pass
			#print_debug("E is empty:", get_cell_atlas_coords(Vector2i(currentRoom.x+1, currentRoom.y)))
		# Check Northern neighbor:
		if currentPaths[1] != Path.ANY:			# Empty: no rooms eliminated
			if currentPaths[1] == Path.CLOSED:	# No S door in N neighbor: remove all w/ N doors
				validAtlasCoords.erase(crossAtlas)
				validAtlasCoords.erase(deadEnd_N_Atlas)
				validAtlasCoords.erase(corner_NE_Atlas)
				validAtlasCoords.erase(corner_NW_Atlas)
				validAtlasCoords.erase(tee_NSW_Atlas)
				validAtlasCoords.erase(tee_NWE_Atlas)
				validAtlasCoords.erase(tee_NES_Atlas)
				validAtlasCoords.erase(hall_NS_Atlas)
				validAtlasCoords.erase(hallBars_NS_Atlas)
				#print_debug("N is closed off:", get_cell_atlas_coords(Vector2i(currentRoom.x, currentRoom.y-1)))
			else:								# S door exists in N neighbor: remove all w/o N doors
				validAtlasCoords.erase(deadEnd_S_Atlas)
				validAtlasCoords.erase(deadEnd_W_Atlas)
				validAtlasCoords.erase(deadEnd_E_Atlas)
				validAtlasCoords.erase(corner_SE_Atlas)
				validAtlasCoords.erase(corner_SW_Atlas)
				validAtlasCoords.erase(tee_ESW_Atlas)
				validAtlasCoords.erase(hall_EW_Atlas)
				validAtlasCoords.erase(hallBars_EW_Atlas)
				#print_debug("N is open:", get_cell_atlas_coords(Vector2i(currentRoom.x, currentRoom.y-1)))
		else:
			pass
			#print_debug("N is empty:", get_cell_atlas_coords(Vector2i(currentRoom.x, currentRoom.y-1)))
		# Check Western neighbor:
		if currentPaths[2] != Path.ANY:			# Empty: no rooms eliminated
			if currentPaths[2] == Path.CLOSED:	# No E door in W neighbor: remove all w/ W doors
				validAtlasCoords.erase(crossAtlas)
				validAtlasCoords.erase(deadEnd_W_Atlas)
				validAtlasCoords.erase(corner_SW_Atlas)
				validAtlasCoords.erase(corner_NW_Atlas)
				validAtlasCoords.erase(tee_NSW_Atlas)
				validAtlasCoords.erase(tee_NWE_Atlas)
				validAtlasCoords.erase(tee_ESW_Atlas)
				validAtlasCoords.erase(hall_EW_Atlas)
				validAtlasCoords.erase(hallBars_EW_Atlas)
				#print_debug("W is closed off:", get_cell_atlas_coords(Vector2i(currentRoom.x-1, currentRoom.y)))
			else:								# E door exists in W neighbor: remove all w/o W doors
				validAtlasCoords.erase(deadEnd_S_Atlas)
				validAtlasCoords.erase(deadEnd_N_Atlas)
				validAtlasCoords.erase(deadEnd_E_Atlas)
				validAtlasCoords.erase(corner_NE_Atlas)
				validAtlasCoords.erase(corner_SE_Atlas)
				validAtlasCoords.erase(tee_NES_Atlas)
				validAtlasCoords.erase(hall_NS_Atlas)
				validAtlasCoords.erase(hallBars_NS_Atlas)
				#print_debug("W is open:", get_cell_atlas_coords(Vector2i(currentRoom.x-1, currentRoom.y)))
		else:
			pass
			#print_debug("W is empty:", get_cell_atlas_coords(Vector2i(currentRoom.x-1, currentRoom.y)))
		# Check Southern neighbor:
		if currentPaths[3] != Path.ANY:			# Empty: no rooms eliminated
			if currentPaths[3] == Path.CLOSED:	# No N door in S neighbor: remove all w/ S doors
				validAtlasCoords.erase(crossAtlas)
				validAtlasCoords.erase(deadEnd_S_Atlas)
				validAtlasCoords.erase(corner_SE_Atlas)
				validAtlasCoords.erase(corner_SW_Atlas)
				validAtlasCoords.erase(tee_NSW_Atlas)
				validAtlasCoords.erase(tee_NES_Atlas)
				validAtlasCoords.erase(tee_ESW_Atlas)
				validAtlasCoords.erase(hall_NS_Atlas)
				validAtlasCoords.erase(hallBars_NS_Atlas)
				#print_debug("S is closed off:", get_cell_atlas_coords(Vector2i(currentRoom.x, currentRoom.y+1)))
			else:								# N door exists in S neighbor: remove all w/o S doors
				validAtlasCoords.erase(deadEnd_W_Atlas)
				validAtlasCoords.erase(deadEnd_N_Atlas)
				validAtlasCoords.erase(deadEnd_E_Atlas)
				validAtlasCoords.erase(corner_NE_Atlas)
				validAtlasCoords.erase(corner_NW_Atlas)
				validAtlasCoords.erase(tee_NWE_Atlas)
				validAtlasCoords.erase(hall_EW_Atlas)
				validAtlasCoords.erase(hallBars_EW_Atlas)
				#print_debug("S is open:", get_cell_atlas_coords(Vector2i(currentRoom.x, currentRoom.y+1)))
		else:
			pass
			#print_debug("S is empty:", get_cell_atlas_coords(Vector2i(currentRoom.x, currentRoom.y+1)))
				
				# ALL POSSIBLE ROOMS:
				#validAtlasCoords.erase(crossAtlas)
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
				#validAtlasCoords.erase(hallBars_NS_Atlas)
				#validAtlasCoords.erase(hallBars_EW_Atlas)
		var roomChoice: Vector2i
		if validAtlasCoords.size() > 0:
			roomChoice = validAtlasCoords[randi() % validAtlasCoords.size()]
		else:
			roomChoice = crossAtlas
		
		var stackSize: int = roomsToGen.size()
		
		# Chance to force re-roll if dead-end room is picked, especially early in dungeon generation
		#if stackSize <= 15 and [deadEnd_S_Atlas, deadEnd_W_Atlas, deadEnd_N_Atlas, deadEnd_E_Atlas].has(roomChoice) and randf() < 1.0 * float(roomsLeft) / float(MAX_CATACOMBS_ROOMS):
			#debug_DeadEndRerolls = debug_DeadEndRerolls + 1
			#continue
		#if stackSize <= 10 and [corner_NE_Atlas, corner_SE_Atlas, corner_SW_Atlas, corner_NW_Atlas,
				#hall_NS_Atlas, hall_EW_Atlas, hallBars_NS_Atlas, hallBars_EW_Atlas].has(roomChoice) and randf() < 1.0 * float(roomsLeft) / float(MAX_CATACOMBS_ROOMS):
			#debug_HallRerolls = debug_HallRerolls + 1
			#continue
		
		set_cell(currentRoom, 1, roomChoice)
		
		var roomsToStack: Array = get_rooms_to_stack(currentRoom)
		for r in roomsToStack:
			roomsToGen.push_back(r) # Breadth-first
			#roomsToGen.push_front(r) # Depth-first
		
		roomsLeft = roomsLeft - 1
	print_debug("Finished dungeon generation with ", roomsLeft, " rooms left of allotted ", MAX_CATACOMBS_ROOMS)
	print_debug("deadEndRerolls=", debug_DeadEndRerolls, ", 4WayRerolls=", debug_4WayRerolls, ", teeRerolls=", debug_TeeRerolls)

func get_rooms_to_stack(newRoom: Vector2i) -> Array:
	var outputArray: Array
	#var paths: Array = findPaths(newRoom)
	if [crossAtlas, deadEnd_E_Atlas, corner_NE_Atlas, corner_SE_Atlas,
		tee_NWE_Atlas, tee_NES_Atlas, tee_ESW_Atlas, hall_EW_Atlas,
		hallBars_EW_Atlas].has(get_cell_atlas_coords(newRoom)): # if newroom has E door
			outputArray.push_back(Vector2i(newRoom.x+1,newRoom.y)) # queue room to be gen'd E
	if [crossAtlas, deadEnd_N_Atlas, corner_NE_Atlas, corner_NW_Atlas,
		tee_NSW_Atlas, tee_NWE_Atlas, tee_NES_Atlas, hall_NS_Atlas,
		hallBars_NS_Atlas].has(get_cell_atlas_coords(newRoom)): # if newroom has N door
			outputArray.push_back(Vector2i(newRoom.x,newRoom.y-1)) # queue room to be gen'd N
	if [crossAtlas, deadEnd_W_Atlas, corner_SW_Atlas, corner_NW_Atlas,
		tee_NSW_Atlas, tee_NWE_Atlas, tee_ESW_Atlas, hall_EW_Atlas,
		hallBars_EW_Atlas].has(get_cell_atlas_coords(newRoom)): # if newroom has W door
			outputArray.push_back(Vector2i(newRoom.x-1,newRoom.y)) # queue room to be gen'd W
	if [crossAtlas, deadEnd_S_Atlas, corner_SE_Atlas, corner_SW_Atlas,
		tee_NSW_Atlas, tee_NES_Atlas, tee_ESW_Atlas, hall_NS_Atlas,
		hallBars_NS_Atlas].has(get_cell_atlas_coords(newRoom)): # if newroom has S door
			outputArray.push_back(Vector2i(newRoom.x,newRoom.y+1)) # queue room to be gen'd S
		
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
		openNeighbors = [startRoomAtlas, crossAtlas, deadEnd_W_Atlas, corner_SW_Atlas,
			corner_NW_Atlas, tee_NSW_Atlas, tee_NWE_Atlas, tee_ESW_Atlas,
			hall_EW_Atlas, hallBars_EW_Atlas] # atlas coords with W facing doors
		if openNeighbors.has(get_cell_atlas_coords(currentNeighbor)):
			outputArray.push_back(Path.OPEN)
		else:
			outputArray.push_back(Path.CLOSED)
	
	# Get status of North neighbor:
	currentNeighbor = Vector2i(room.x, room.y-1)
	if get_cell_atlas_coords(currentNeighbor) == emptyAtlas:
		outputArray.push_back(Path.ANY)
	else:
		openNeighbors = [startRoomAtlas, crossAtlas, deadEnd_S_Atlas, corner_SE_Atlas,
			corner_SW_Atlas, tee_NSW_Atlas, tee_NES_Atlas, tee_ESW_Atlas,
			hall_NS_Atlas, hallBars_NS_Atlas] # atlas coords with S facing doors
		if openNeighbors.has(get_cell_atlas_coords(currentNeighbor)):
			outputArray.push_back(Path.OPEN)
		else:
			outputArray.push_back(Path.CLOSED)
	
	# Get status of West neighbor:
	currentNeighbor = Vector2i(room.x-1, room.y)
	if get_cell_atlas_coords(currentNeighbor) == emptyAtlas:
		outputArray.push_back(Path.ANY)
	else:
		openNeighbors = [startRoomAtlas, crossAtlas, deadEnd_E_Atlas, corner_NE_Atlas,
			corner_SE_Atlas, tee_NWE_Atlas, tee_NES_Atlas, tee_ESW_Atlas,
			hall_EW_Atlas, hallBars_EW_Atlas] # atlas coords with E facing doors
		if openNeighbors.has(get_cell_atlas_coords(currentNeighbor)):
			outputArray.push_back(Path.OPEN)
		else:
			outputArray.push_back(Path.CLOSED)
	
	# Get status of South neighbor:
	currentNeighbor = Vector2i(room.x, room.y+1)
	if get_cell_atlas_coords(currentNeighbor) == emptyAtlas:
		outputArray.push_back(Path.ANY)
	else:
		openNeighbors = [crossAtlas, deadEnd_N_Atlas, corner_NE_Atlas, corner_NW_Atlas,
			tee_NSW_Atlas, tee_NWE_Atlas, tee_NES_Atlas, hall_NS_Atlas,
			hallBars_NS_Atlas] # atlas coords with N facing doors
		if openNeighbors.has(get_cell_atlas_coords(currentNeighbor)):
			outputArray.push_back(Path.OPEN)
		else:
			outputArray.push_back(Path.CLOSED)
	
	return outputArray


#func build_walls() -> void:
	#for i in range(width):
		#for j in range(height):
			#if not(get_cell_tile_data(Vector2i(i,j))):
				#var E = get_cell_tile_data(Vector2i(i+1,j))
				#var N = get_cell_tile_data(Vector2i(i,j-1))
				#var W = get_cell_tile_data(Vector2i(i-1,j))
				#var S = get_cell_tile_data(Vector2i(i,j+1))
				#if E or N or W or S:
					#set_cell(Vector2i(i, j), 0, wallAtlas)
