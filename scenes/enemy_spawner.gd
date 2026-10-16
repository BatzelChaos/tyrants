# enemy_spawner.gd
extends Node2D

const TILE_SIZE := 32.0  # keep in sync with player.gd / enemy.gd

@export var enemy_scene: PackedScene
@export var cells: Array[Vector2i] = []  # tile offsets from this node; (0,0) = spawner's own tile


func _ready() -> void:
	for cell in cells:
		spawn_at(cell)


func spawn_at(cell: Vector2i) -> Node:
	var enemy: Node2D = enemy_scene.instantiate()
	enemy.position = Vector2(cell) * TILE_SIZE  # local offset; spawner must be unrotated/unscaled
	add_child(enemy)
	return enemy
