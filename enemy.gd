extends GridCharacter


func _setup_character() -> void:
	add_to_group("enemies")
	add_to_group("interactable")


func interact(player: Node) -> void:
	print("%s interacted with %s" % [player.name, name])
