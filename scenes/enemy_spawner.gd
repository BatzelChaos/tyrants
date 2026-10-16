extends Node2D

const TILE_SIZE := 32.0

@export var scenes: Dictionary[Vector2i, PackedScene] = {}   # 4.3 or older: drop the types
@export var spawn_layer_name := "Spawns"   # rename to match your layer, e.g. "EnemyLayer"


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
		enemy.set("wanders", layer.get_cell_tile_data(cell).get_custom_data("wanders"))
		var half := Vector2(enemy.get("footprint")) * TILE_SIZE * 0.5
		enemy.position = Vector2(cell) * TILE_SIZE + half
		map.add_child(enemy)   # <- parented to the map: freed together with it
	layer.clear()
