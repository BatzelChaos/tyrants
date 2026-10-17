class_name Enemy
extends GridCharacter

@export var display_name := "Placeholder"
@export var max_health := 30
var health := 30
@export var attack_damage := Vector2i(4, 12)  # min/max damage dealt in battle
@export var defense := 10
@export var exp := 100
var spawn_id := ""  # "map|layer|cell", set by map.gd at spawn time


func _setup_character() -> void:
	add_to_group("enemies")
	add_to_group("interactable")
	health = max_health


func interact(player: Node) -> void:
	# Player faced/bumped into this enemy -> battle.
	get_tree().call_group("game", "start_battle", self)


func _on_player_collision(player: Node) -> void:
	pass  # touching you doesn't start a fight; player-initiated interact does.
	# For touch-encounters, put the call_group line from interact() here instead.
