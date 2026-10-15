extends Camera2D

@export var follow_speed: float = 8.0  # 2 = very lazy, 15 = almost rigid

var target: Node2D


func _physics_process(delta: float) -> void:
	if target == null:
		target = get_tree().get_first_node_in_group("player")
		if target == null:
			return
		global_position = target.global_position  # no slide on spawn
		return

	# Frame-rate independent exponential smoothing
	var t := 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(target.global_position, t)
