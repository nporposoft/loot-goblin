extends Detector

var dungeon: PackedScene = load("res://test_dungeon.tscn")

var transition_started: bool = false

func _process(delta: float) -> void:
	if not transition_started:
		for c in get_characters():
			if c._get_faction() == c.Faction.GOBLIN:
				begin_transition()
				transition_started = true


func begin_transition() -> void:
	var end_timer = Timer.new()
	add_child(end_timer)
	end_timer.one_shot = true
	end_timer.connect("timeout", load_dungeon)
	end_timer.start(10.0)


func load_dungeon() -> void:
	ScoreKeeper._reset_score()
	get_tree().change_scene_to_packed(dungeon)
