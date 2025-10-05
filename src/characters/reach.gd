class_name Reach
extends Detector


func get_interactables() -> Array[Interactable]:
	var interactables_in_reach: Array[Interactable] = []
	for interactable in get_all():
		if interactable is Interactable: interactables_in_reach.append(interactable)
	return interactables_in_reach


func get_triggers() -> Array[Trigger]:
	var triggers_in_reach: Array[Trigger] = []
	for trigger in get_all():
		if trigger is Trigger: triggers_in_reach.append(trigger)
	return triggers_in_reach


func get_items() -> Array[Item]:
	var items_in_reach: Array[Item] = []
	for item in get_all():
		if item is Item: items_in_reach.append(item)
	return items_in_reach

