extends Node2D

@onready var spawn_point = $SpawnPoint
@onready var characters = $Characters

func _ready():
	var character_scene = GameManager.selected_character

	if character_scene == null:
		push_warning("No character selected!")
		return

	var character = character_scene.instantiate()
	characters.add_child(character)
	character.global_position = spawn_point.global_position
