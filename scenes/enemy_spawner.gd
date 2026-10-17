extends Node2D

const TILE_SIZE := 32.0

@export var scenes: Dictionary[Vector2i, PackedScene] = {}   # 4.3 or older: drop the types
@export var spawn_layer_name := "Spawns"   # rename to match your marker layer in map.tscn


func spawn_from(map: Node) -> void:
	var layer := map.find_child(spawn_layer_name, true, false) as TileMapLayer
	if layer == null:
		push_warning("No marker layer '%s' in %s" % [spawn_layer_name, map.name])
		return

	for cell in layer.get_used_cells():
		var atlas := layer.get_cell_atlas_coords(cell)
		if not scenes.has(atlas):
			push_warning("No scene mapped for marker %s at %s" % [atlas, cell])
			continue

		var enemy: Node2D = scenes[atlas].instantiate()
		var tile_data := layer.get_cell_tile_data(cell)

		# Only touch properties the enemy script actually has.
		if "wanders" in enemy:
			enemy.set("wanders", tile_data.get_custom_data("wanders") == true)

		# The marker tile is the TOP-LEFT tile of the footprint.
		var half := Vector2.ONE * TILE_SIZE * 0.5
		if "footprint" in enemy:
			half = Vector2(enemy.get("footprint")) * TILE_SIZE * 0.5
		enemy.position = Vector2(cell) * TILE_SIZE + half

		map.add_child(enemy)   # <- parented to the map: freed together with it

	layer.clear()
