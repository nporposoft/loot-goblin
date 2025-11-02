extends Node


var Score: float = 0
var DisplayedScore: float = 0
var logTime: float = 0.0
var itemLog: Array = []

const tau: float = 0.632 # τ = 1 time constant = 63.2% of change to final state (EE reference; just let me have this)


func _process(delta: float) -> void:
	logTime += delta
	if DisplayedScore < Score - 1:
		DisplayedScore += delta * (Score - DisplayedScore) * tau
	else: DisplayedScore = Score


func _score_item(itemDataToScore: ItemData) -> void:
	if itemDataToScore.is_container:
		for i in itemDataToScore.items:
			_score_item(i)
	_add_score(itemDataToScore.shininess)
	_log_item(logTime, itemDataToScore)


func _add_score(addedScore: int) -> void:
	Score += addedScore


func _log_item(timeLogged: float, dataToLog: ItemData) -> void:
	itemLog.append([timeLogged, dataToLog])

func _reset_score() -> void:
	Score = 0.0
	DisplayedScore = Score
	itemLog.clear()
