extends Node

var Score: float = 0
var DisplayedScore: float = 0

func _process(delta) -> void:
	if DisplayedScore < Score:
		DisplayedScore = DisplayedScore + delta * (Score - DisplayedScore) * 0.33
		DisplayedScore = DisplayedScore + delta * (Score - DisplayedScore)

func _add_score(addedScore: int) -> void:
	Score = Score + addedScore
