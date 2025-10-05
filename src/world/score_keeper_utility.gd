extends Node

var Score: float = 0.0
var DisplayedScore: float = 0.0

func _process(delta) -> void:
	if DisplayedScore < Score:
		DisplayedScore = DisplayedScore + ceil(delta * (Score - DisplayedScore) * 0.2)

func _add_score(addedScore: float) -> void:
	Score = Score + addedScore
