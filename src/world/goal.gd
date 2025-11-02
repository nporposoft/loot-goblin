class_name Goal
extends Detector


@export var scoreDelay: float = 1.5 # TODO


func _process(delta: float) -> void:
	for thisItem in get_items():
		ScoreKeeper._score_item(thisItem.item_data)
		#if thisItem.item_data.is_container:# and thisItem.item_data.items.size() > 0:
			#for i in thisItem.item_data.items:
				#_score_item(i)
		#_score_item(thisItem.item_data)
		thisItem.destroy()

#func _score_item(data: ItemData) -> void:
	#ScoreKeeper._add_score(data.shininess)
