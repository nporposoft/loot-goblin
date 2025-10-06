class_name GameOver
extends Control

@export var player_character: Character


func _ready() -> void:
	player_character.died.connect(show_game_over)


func show_game_over() -> void:
	visible = true
