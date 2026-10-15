extends CharacterBody2D

const TILE_SIZE := 32.0
@export var move_speed: float = 100.0
@export_range(1.0, 4.0, 0.1) var run_multiplier: float = 1.6  # Shift sprint speed
@export var max_health: int = 100
var health: int = 100

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_direction := Vector2i.DOWN

var grid_origin := Vector2.ZERO      # world position of cell (0,0) = the start position
var grid_cell := Vector2i.ZERO       # the cell the character occupies when idle
var move_direction := Vector2i.ZERO  # direction of the move currently in progress
var target_position := Vector2.ZERO
var is_moving := false
var _anchored := false

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not _anchored:
		_anchored = true
		grid_origin = global_position
		grid_cell = Vector2i.ZERO
		target_position = global_position

	# Run state is sampled once per tick, so budget, velocity and
	# animation all stay consistent within the tick.
	var speed := _current_speed()
	var budget := speed * delta  # how far we may travel this tick

	while budget > 0.0:
		if not is_moving:
			var dir := _read_input_direction()
			if dir == Vector2i.ZERO:
				# Input released: this is a real stop.
				stop_walk_animation()
				break
			move_direction = dir
			target_position = cell_position(grid_cell + dir)
			is_moving = true
			play_walk_animation(dir)

		var to_target := global_position.distance_to(target_position)

		if to_target > budget:
			# Mid-tile: use up the rest of the budget.
			var collision := move_and_collide(
				global_position.direction_to(target_position) * budget
			)
			if collision:
				# Blocked: return to the cell we came from.
				global_position = cell_position(grid_cell)
				target_position = global_position
				move_direction = Vector2i.ZERO
				is_moving = false
				velocity = Vector2.ZERO
				stop_walk_animation()
				break
			budget = 0.0
		else:
			# Arrive, lock onto the cell, chain into the next tile
			# with the leftover budget.
			global_position = target_position
			grid_cell += move_direction
			move_direction = Vector2i.ZERO
			is_moving = false
			velocity = Vector2.ZERO
			budget -= to_target

	velocity = (
		global_position.direction_to(target_position) * speed
		if is_moving
		else Vector2.ZERO
	)

	# Stride faster while running; idle animations keep normal speed.
	animated_sprite.speed_scale = (
		run_multiplier if (is_moving and _is_running())
		else 1.0
	)


func _is_running() -> bool:
	# return Input.is_action_pressed("run")
	# Fallback without an Input Map action:
	return Input.is_key_pressed(KEY_SHIFT)


func _current_speed() -> float:
	return move_speed * run_multiplier if _is_running() else move_speed


func _read_input_direction() -> Vector2i:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input == Vector2.ZERO:
		return Vector2i.ZERO
	# Dominant axis only - one tile at a time.
	if absf(input.x) > absf(input.y):
		return Vector2i(1 if input.x > 0.0 else -1, 0)
	return Vector2i(0, 1 if input.y > 0.0 else -1)


func cell_position(cell: Vector2i) -> Vector2:
	return grid_origin + Vector2(cell) * TILE_SIZE


func play_walk_animation(dir: Vector2i) -> void:
	last_direction = dir

	if dir.x != 0:
		animated_sprite.flip_h = dir.x < 0
		animated_sprite.play("walk_side")
	elif dir.y < 0:
		animated_sprite.play("walk_up")
	else:
		animated_sprite.play("walk_down")


func stop_walk_animation() -> void:
	match last_direction:
		Vector2i.UP:
			animated_sprite.play("idle_up")
		Vector2i.DOWN:
			animated_sprite.play("idle_down")
		Vector2i.LEFT, Vector2i.RIGHT:
			animated_sprite.play("idle_side")
			
func get_save_data() -> Dictionary:
	var pos := cell_position(grid_cell) if is_moving else global_position
	return {
		"position_x": pos.x,
		"position_y": pos.y,
		"health": health,
		"grid_cell_x": grid_cell.x,
		"grid_cell_y": grid_cell.y,
		"last_direction_x": last_direction.x,
		"last_direction_y": last_direction.y,
	}


func load_save_data(data: Dictionary) -> void:
	health = int(data.get("health", max_health))

	grid_cell = Vector2i(
		int(data.get("grid_cell_x", 0)),
		int(data.get("grid_cell_y", 0))
	)
	global_position = Vector2(
		float(data.get("position_x", global_position.x)),
		float(data.get("position_y", global_position.y))
	)
	grid_origin = global_position - Vector2(grid_cell) * TILE_SIZE  # AFTER grid_cell

	last_direction = Vector2i(
		int(data.get("last_direction_x", 0)),
		int(data.get("last_direction_y", 1))
	)

	target_position = global_position
	move_direction = Vector2i.ZERO
	is_moving = false
	_anchored = true
	stop_walk_animation()
