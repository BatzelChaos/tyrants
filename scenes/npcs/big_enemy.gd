extends CharacterBody2D

const TILE_SIZE := 32.0  # keep in sync with player.gd

@export var move_speed := 60.0
@export var wanders := false                  # tick in the Inspector for movers only
@export var idle_time := Vector2(1.0, 3.0)    # min/max seconds between steps

var grid_cell := Vector2i.ZERO      # anchor = top-left occupied cell
var target_position := Vector2.ZERO
var is_moving := false
var move_direction := Vector2i.ZERO
var _anchored := false
var _idle_timer := 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("enemies")
	add_to_group("interactable")


func _physics_process(delta: float) -> void:
	if not _anchored:
		_anchored = true
		# Centered 64x64 sprite: snap the footprint center to a tile crossing.
		var top_left := global_position - Vector2.ONE * TILE_SIZE
		grid_cell = Vector2i((top_left / TILE_SIZE).floor())
		global_position = cell_position(grid_cell)
		target_position = global_position
		_idle_timer = randf_range(idle_time.x, idle_time.y)

	# Stationary: aligned on spawn, then completely inert.
	if not wanders:
		return

	var budget := move_speed * delta
	while budget > 0.0:
		if not is_moving:
			var dir := _next_direction(delta)
			if dir == Vector2i.ZERO:
				break
			move_direction = dir
			target_position = cell_position(grid_cell + dir)
			is_moving = true
			if dir.x != 0:
				sprite.flip_h = dir.x < 0

		var to_target := global_position.distance_to(target_position)
		if to_target > budget:
			var collision := move_and_collide(
				global_position.direction_to(target_position) * budget
			)
			if collision:
				var collider := collision.get_collider()
				if collider is Node and collider.is_in_group("player"):
					interact(collider)
				global_position = cell_position(grid_cell)
				target_position = global_position
				move_direction = Vector2i.ZERO
				is_moving = false
				break
			budget = 0.0
		else:
			global_position = target_position
			grid_cell += move_direction
			move_direction = Vector2i.ZERO
			is_moving = false
			budget -= to_target

	velocity = Vector2.ZERO


func _next_direction(delta: float) -> Vector2i:
	_idle_timer -= delta
	if _idle_timer > 0.0:
		return Vector2i.ZERO
	_idle_timer = randf_range(idle_time.x, idle_time.y)
	var dirs: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	return dirs.pick_random()


func cell_position(cell: Vector2i) -> Vector2:
	# Node origin = center of the 2x2 block (a tile crossing).
	return (Vector2(cell) + Vector2.ONE) * TILE_SIZE


func occupies(cell: Vector2i) -> bool:
	return cell.x >= grid_cell.x and cell.x < grid_cell.x + 2 \
		and cell.y >= grid_cell.y and cell.y < grid_cell.y + 2


func get_occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in 2:
		for x in 2:
			cells.append(grid_cell + Vector2i(x, y))
	return cells


func interact(player: Node) -> void:
	print("%s interacted with %s" % [player.name, name])
