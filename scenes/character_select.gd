extends Control

const CHARACTERS = [
	preload("res://scenes/characters/kaniel.tscn"),
	preload("res://scenes/characters/biene.tscn"),
	preload("res://scenes/characters/avanch.tscn"),
	preload("res://scenes/characters/cro.tscn")
]

func _on_kaniel_pressed():
	GameManager.selected_character = CHARACTERS[0]

func _on_biene_pressed():
	GameManager.selected_character = CHARACTERS[1]

func _on_avanch_pressed():
	GameManager.selected_character = CHARACTERS[2]

func _on_cro_pressed():
	GameManager.selected_character = CHARACTERS[3]

func _on_start_pressed():
	if GameManager.selected_character != null:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
