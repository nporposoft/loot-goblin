extends Node

var Score: int = 0
var DisplayedScore: int = 0

func _process(delta) -> void:
	if DisplayedScore < Score:
		DisplayedScore = DisplayedScore + ceil(delta * (Score - DisplayedScore) * 0.2)
		DisplayedScore = DisplayedScore + ceil(delta * (Score - DisplayedScore))

func _add_score(addedScore: int) -> void:
	Score = Score + addedScore
