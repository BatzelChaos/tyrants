extends Control

@onready var start_button: Button = $HBoxContainer/VBoxContainer/start_button
@onready var continue_button: Button = $HBoxContainer/VBoxContainer/continue_button
@onready var settings_button: Button = $HBoxContainer/VBoxContainer/settings_button
@onready var exit_button: Button = $HBoxContainer/VBoxContainer/exit_button


func _ready() -> void:
	start_button.pressed.connect(_on_play_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	continue_button.visible = GameManager.has_save


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")

func _on_continue_pressed() -> void:
	GameManager.start_game(true)


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
