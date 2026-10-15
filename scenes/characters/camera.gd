extends Camera2D

@export var follow_speed: float = 5.0

func _ready() -> void:
	enabled = true
	#position_smoothing_enabled = false
	make_current()

func _process(delta: float) -> void:
	global_position = global_position.lerp(
		get_parent().global_position,
		1.0 - exp(-follow_speed * delta)
	)
