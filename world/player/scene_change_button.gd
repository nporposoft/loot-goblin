class_name SceneChangeButton
extends Button

@export_file var target_scene_path: String

@onready var target_scene: PackedScene = load(target_scene_path)


func _ready():
	pressed.connect(func():
		get_tree().change_scene_to_packed(target_scene)
	)
