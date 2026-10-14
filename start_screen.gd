extends Control

@onready var start_button: Button = $HBoxContainer/VBoxContainer/start_button
@onready var settings_button: Button = $HBoxContainer/VBoxContainer/settings_button
@onready var exit_button: Button = $HBoxContainer/VBoxContainer/exit_button


func _ready() -> void:
	start_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
