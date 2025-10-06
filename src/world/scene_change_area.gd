class_name SceneChangeArea
extends Detector

@export var next_scene: PackedScene
@export var transition_time: float = 0.0

var transition_started: bool = false

func _process(_delta: float) -> void:
	if not transition_started:
		for c in get_characters():
			if c._get_faction() == c.Faction.GOBLIN:
				print("Beginning transition to next scene: ", next_scene)
				begin_transition()
				transition_started = true


func begin_transition() -> void:
	var end_timer = Timer.new()
	add_child(end_timer)
	end_timer.one_shot = true
	end_timer.connect("timeout", load_dungeon)
	end_timer.start(transition_time)


func load_dungeon() -> void:
	print("Loading next scene: ", next_scene)
	ScoreKeeper._reset_score()
	get_tree().change_scene_to_packed(next_scene)
