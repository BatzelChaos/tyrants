extends Node

var selected_character: PackedScene

const SAVE_PATH := "user://savegame.json"
var current_map_path: String = "res://scenes/maps/test_map.tscn"

const CHARACTER_PATHS := {
	"kaniel": "res://scenes/characters/kaniel.tscn",
	"biene": "res://scenes/characters/biene.tscn",
	"avanch": "res://scenes/characters/avanch.tscn",
	"cro": "res://scenes/characters/cro.tscn"
}

var selected_character_id: String = "kaniel"

var player_position: Vector2 = Vector2.ZERO
var player_health: int = 100
var has_save: bool = false


func select_character(id: String) -> void:
	if not CHARACTER_PATHS.has(id):
		return

	selected_character_id = id
	selected_character = load(CHARACTER_PATHS[id])


func save_game() -> void:
	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("Cannot save: player not found.")
		return

	var save_data: Dictionary = player.get_save_data()
	save_data["character"] = selected_character_id
	save_data["map"] = current_map_path

	var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)

	if file == null:
		push_error("Could not open save file.")
		return

	file.store_string(JSON.stringify(save_data))
	file.close()

	print("Game saved!")


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false

	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()

	if error != OK or not json.data is Dictionary:
		push_error("Invalid save file.")
		return false

	var data: Dictionary = json.data
	var character_id := str(data.get("character", ""))

	if not CHARACTER_PATHS.has(character_id):
		return false

	selected_character_id = character_id
	selected_character = load(CHARACTER_PATHS[character_id])

	player_position = Vector2(
		float(data.get("position_x", 0.0)),
		float(data.get("position_y", 0.0))
	)
	player_health = int(data.get("health", 100))

	has_save = true
	return true
	
func change_map(path: String) -> void:
	current_map_path = path
	get_tree().change_scene_to_file(path)
