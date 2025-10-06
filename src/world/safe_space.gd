class_name SafeSpace
extends Detector

@export var safe_factions: Array[Character.Faction] = [Character.Faction.GOBLIN]


func _ready() -> void:
	body_entered.connect(func(body: Node) -> void:
		if body is Character and body.faction in safe_factions:
			body.is_invisible = true
	)
	body_exited.connect(func(body: Node) -> void:
		if body is Character and body.faction in safe_factions:
			body.is_invisible = false
	)

