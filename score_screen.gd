extends Control


@onready var spawnLocus: Node2D = $Hole/SpawnLocus
@onready var buttonMainMenu: Button = $"UI/Main Menu"
@onready var buttonRetry: Button = $"UI/Try Again"

var lootLog: Array
var startingTimer: Timer
var replayTime: float = 0.0
var replaying: bool = false

const REPLAY_DELAY: float = 1.0
const MAX_ABS_X_IMPULSE: float = 0.1
const MAX_ABS_Y_IMPULSE: float = 0.1


func _init() -> void:
	lootLog = ScoreKeeper.itemLog
	#startingTimer = Timer.new()
	#startingTimer.one_shot = true
	#startingTimer.timeout.connect(_replay_start)
	#self.add_child(startingTimer)
	#startingTimer.start(REPLAY_DELAY)

func _ready():
	_replay_start()

func _process(delta: float) -> void:
	if replaying:
		replayTime += 2 * (replayTime + 0.1) * delta # exponential speed: 2*t*delta = delta * d/dt of t^2
		print(replayTime)
		while lootLog.size() > 0 and replayTime >= lootLog[0][0]:
			#print("SUCCESS! itemTime=",lootLog[0][0])
			_toss_loot(lootLog.pop_front()[1])
			#if lootLog.size() == 0: print("lootLog empty!")
	if lootLog.size() == 0: replaying = false

func _replay_start() -> void:
	replaying = true
	buttonMainMenu.visible = true
	buttonRetry.visible = true

func _replay_finish() -> void:
	pass

func _toss_loot(itemToToss: ItemData) -> void:
	var tossedItem: RigidBody2D = itemToToss.item_scene.instantiate()
	self.add_child(tossedItem)
	tossedItem.position = spawnLocus.position
	tossedItem.lock_rotation = false
	tossedItem.freeze = false
	tossedItem.mass = 1.0
	tossedItem.gravity_scale = 1.0
	tossedItem.apply_impulse(Vector2(-10.0 - MAX_ABS_X_IMPULSE, 0.0 - randi() * MAX_ABS_Y_IMPULSE), Vector2(0.0, 0.0))
