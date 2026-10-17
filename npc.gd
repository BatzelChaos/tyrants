extends GridCharacter

## Tick in the Inspector so the player can talk to this NPC.
@export var interactable := false
## Feeds your dialogue system later; used by the placeholder print for now.
@export var display_name := "Villager"


func _setup_character() -> void:
	add_to_group("npcs")
	if interactable:
		add_to_group("interactable")


func interact(player: Node) -> void:
	if not interactable:
		return
	# Replace with your dialogue system, e.g. a signal or Dialogic.start(...)
	print("%s talks to %s" % [player.name, display_name])


func _on_player_collision(player: Node) -> void:
	# NPCs never start conversations by bumping into you,
	# but they at least turn to look at you.
	if player is Node2D:
		sprite.flip_h = (player as Node2D).global_position.x < global_position.x
