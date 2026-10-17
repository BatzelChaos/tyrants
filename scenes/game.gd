extends Node2D

const BATTLE_SCENE := preload("res://scenes/battle_scene.tscn")  # ← adjust to your path

@onready var characters: Node2D = $Characters
@onready var maps: Node2D = $Maps
@onready var camera: Camera2D = $Camera2D

var current_map: Node2D
var player: Player

var _battle: BattleScene
var _battle_enemy: Enemy


func _ready() -> void:
	add_to_group("game")

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


func load_map(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Map does not exist: " + path)
		return

	if current_map != null:
		current_map.queue_free()

	var scene := load(path) as PackedScene
	current_map = scene.instantiate() as Node2D
	maps.add_child(current_map)
	GameManager.current_map_path = path


func _get_player_spawn_position() -> Vector2:
	if current_map != null:
		var map_spawn := current_map.get("spawn_point") as Node2D
		if map_spawn != null:
			return map_spawn.global_position
		# No SpawnPoint in this map: start at the map's origin instead.
		push_warning("Map '%s' has no SpawnPoint - spawning at its origin." % current_map.name)
		return current_map.global_position
	push_warning("No map loaded - spawning at origin.")
	return Vector2.ZERO


# ---- Battles ---------------------------------------------------------------

func start_battle(enemy: Enemy) -> void:
	if _battle != null or not is_instance_valid(enemy):
		return

	_battle_enemy = enemy
	_battle = BATTLE_SCENE.instantiate() as BattleScene
	add_child(_battle)   # _ready runs here: buttons connect, process mode set
	_battle.setup(enemy, player)   # battle reads name/stats straight from the nodes
	_battle.finished.connect(_on_battle_finished)

	# Freeze the world; the map stays in memory and resumes untouched.
	get_tree().paused = true


func _on_battle_finished(outcome: int) -> void:
	get_tree().paused = false

	_battle.queue_free()
	_battle = null

	match outcome:
		BattleScene.Outcome.VICTORY:
			if is_instance_valid(_battle_enemy):
				# Dead for the rest of this game - even after re-entering the map.
				GameManager.defeat_enemy(_battle_enemy.spawn_id)
				_battle_enemy.queue_free()
		BattleScene.Outcome.DEFEAT:
			player.health = player.max_health
			_respawn_player()
		BattleScene.Outcome.FLED:
			pass  # enemy stays; player HP was already synced live during the battle

	_battle_enemy = null

func _respawn_player() -> void:
	if current_map == null or current_map.scene_file_path != GameManager.RESPAWN_MAP_PATH:
		load_map(GameManager.RESPAWN_MAP_PATH)

	# RespawnPoint is the intended target, SpawnPoint is the backup,
	# the map origin is the last resort so a marker-less map can't soft-lock.
	var point := current_map.get("respawn_point") as Node2D
	if point == null:
		point = current_map.get("spawn_point") as Node2D
	if point != null:
		player.teleport_to(point.global_position)
	else:
		push_warning("Respawn map '%s' has no markers - respawning at its origin." % current_map.name)
		player.teleport_to(current_map.global_position)

	camera.global_position = player.global_position  # snap, don't pan across the map
