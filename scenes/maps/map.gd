extends Node2D

const TILE_SIZE := 32.0

@export var enemy_layer_name := "Enemies"
@export var npc_layer_name := "NPCs"
@export var enemy_scenes: Dictionary[Vector2i, PackedScene] = {}  # 4.3 or older: drop the types
@export var npc_scenes: Dictionary[Vector2i, PackedScene] = {}    # 4.3 or older: drop the types

# Optional: drop a Marker2D named "SpawnPoint" into this map and the
# player will enter here instead of the game-level spawn point.
@onready var spawn_point: Marker2D = get_node_or_null("SpawnPoint") as Marker2D
@onready var respawn_point: Marker2D = get_node_or_null("RespawnPoint") as Marker2D

func _ready() -> void:
	_spawn_layer(enemy_layer_name, enemy_scenes)
	_spawn_layer(npc_layer_name, npc_scenes)


func _spawn_layer(layer_name: String, scenes: Dictionary[Vector2i, PackedScene]) -> void:
	var layer := find_child(layer_name, true, false) as TileMapLayer
	if layer == null:
		if not scenes.is_empty():
			push_warning("No spawn layer '%s' in %s" % [layer_name, name])
		return

	for cell in layer.get_used_cells():
		var atlas := layer.get_cell_atlas_coords(cell)
		if not scenes.has(atlas):
			push_warning("No scene mapped for marker %s at %s" % [atlas, cell])
			continue

		var character: Node2D = scenes[atlas].instantiate()
		# Defeated enemies stay gone for the whole game (until a new game).
		if character is Enemy:
			var enemy := character as Enemy
			var spawn_id := "%s|%s|%s" % [scene_file_path, layer_name, cell]
			if GameManager.is_enemy_defeated(spawn_id):
				enemy.queue_free()
				continue
			enemy.spawn_id = spawn_id
		var tile_data := layer.get_cell_tile_data(cell)

		# Only touch properties the character script actually has.
		if "wanders" in character:
			character.set("wanders", tile_data.get_custom_data("wanders") == true)

		# Marker tile = top-left tile of the footprint.
		var half := Vector2.ONE * TILE_SIZE * 0.5
		if "footprint" in character:
			half = Vector2(character.get("footprint")) * TILE_SIZE * 0.5
		character.position = Vector2(cell) * TILE_SIZE + half

		add_child(character)   # <- parented to the map: freed together with it

	layer.clear()
