extends Node2D

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var characters: Node2D = $Characters
@onready var maps: Node2D = $Maps
@onready var camera: Camera2D = $Camera2D

var current_map: Node2D
var player: CharacterBody2D


func _ready() -> void:
	player = GameManager.get_character_scene().instantiate()
	characters.add_child(player)

	load_map(GameManager.current_map_path)

	if GameManager.pending_save_data.is_empty():
		player.global_position = _get_player_spawn_position()
	else:
		player.load_save_data(GameManager.pending_save_data)

	camera.position_smoothing_enabled = false
	camera.make_current()
	camera.global_position = player.global_position


func _process(delta: float) -> void:
	if is_instance_valid(player):
		var weight := 1.0 - exp(-5.0 * delta)
		camera.global_position = camera.global_position.lerp(
			player.global_position,
			weight
		)


func _get_player_spawn_position() -> Vector2:
	# The map's own SpawnPoint wins; fall back to the one in game.tscn.
	if current_map != null:
		var map_spawn := current_map.get("spawn_point") as Node2D
		if map_spawn != null:
			return map_spawn.global_position
	return spawn_point.global_position

func load_map(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Map does not exist: " + path)
		return

	if current_map != null:
		current_map.queue_free()

	var scene := load(path) as PackedScene
	current_map = scene.instantiate() as Node2D
	maps.add_child(current_map)   # map.gd spawns its own enemies/NPCs in _ready()
	GameManager.current_map_path = path
