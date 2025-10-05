extends Label


func _process(delta: float) -> void:
	text = str(int(ceil(ScoreKeeper.DisplayedScore)))
