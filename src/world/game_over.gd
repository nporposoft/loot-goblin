class_name GameOver
extends Control

@export var player_character: Character
@onready var endScene: PackedScene = load("res://score_screen.tscn")
@onready var ohNoLabel = $"Oh no"


func _ready() -> void:
	player_character.died.connect(show_game_over_screen)


func show_game_over_screen() -> void:
	ohNoLabel.visible = true
	get_tree().change_scene_to_packed(endScene)
