class_name Goal
extends Detector


@export var scoreDelay: float = 1.5 # TODO


func _process(delta: float):
	for item in get_items():
		if item.item_data.is_container:# and item.item_data.items.size() > 0:
			for i in item.item_data.items:
				_score_item(i)
		_score_item(item.item_data)
		item.destroy()

func _score_item(data: ItemData) -> void:
	ScoreKeeper._add_score(data.shininess)
