class_name Detector
extends Area2D


func get_all() -> Array[Node]:
	var in_reach: Array[Node] = []
	for node in get_overlapping_bodies():
		in_reach.append(node)
	for node in get_overlapping_areas():
		in_reach.append(node)
	return in_reach


