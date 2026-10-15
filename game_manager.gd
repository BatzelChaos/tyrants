extends Node

const SAVE_PATH := "user://savegame.json"

const CHARACTER_PATHS := {
	"kaniel": "res://scenes/characters/kaniel.tscn",
	"biene": "res://scenes/characters/biene.tscn",
	"avanch": "res://scenes/characters/avanch.tscn",
	"cro": "res://scenes/characters/cro.tscn",
}

var selected_character_id: String = "kaniel"
var current_map_path: String = "res://scenes/maps/test_map.tscn"
var settings_return_to: String = "start_screen"

# Non-empty when the next game.tscn load should restore a save.
var pending_save_data: Dictionary = {}

var has_save: bool = false


func _ready() -> void:
	has_save = FileAccess.file_exists(SAVE_PATH)


func select_character(id: String) -> void:
	if CHARACTER_PATHS.has(id):
		selected_character_id = id


func get_character_scene() -> PackedScene:
	return load(CHARACTER_PATHS[selected_character_id])


func start_game(from_save: bool) -> void:
	pending_save_data = {}
	if from_save and not load_game():
		return  # load failed; stay on the menu
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func save_game() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("Cannot save: player not found.")
		return
	if not player.has_method("get_save_data"):
		push_error("Player script is missing get_save_data().")
		return

	var data: Dictionary = player.get_save_data()
	data["character"] = selected_character_id
	data["map"] = current_map_path

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file: %s" % error_string(FileAccess.get_open_error()))
		return

	file.store_string(JSON.stringify(data, "\t"))
	has_save = true
	print("Game saved!")


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not read save file: %s" % error_string(FileAccess.get_open_error()))
		return false

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("Save file corrupted (line %d): %s" % [json.get_error_line(), json.get_error_message()])
		return false

	var data = json.data
	if not data is Dictionary:
		push_error("Save file has unexpected format.")
		return false

	var character_id := str(data.get("character", ""))
	if not CHARACTER_PATHS.has(character_id):
		push_error("Save file references unknown character '%s'." % character_id)
		return false

	selected_character_id = character_id
	current_map_path = str(data.get("map", current_map_path))
	pending_save_data = data
	return true


func change_map(path: String) -> void:
	current_map_path = path
	get_tree().change_scene_to_file(path)
