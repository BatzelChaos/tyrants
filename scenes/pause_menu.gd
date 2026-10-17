extends Control

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

var settings_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	scale = Vector2(0.4, 0.4)

	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	scale = Vector2(0.4, 0.4)
	pivot_offset = size / 2.0


func _unhandled_key_input(event: InputEvent) -> void:
	if settings_open:
		return
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	show()
	get_tree().paused = true
	resume_button.grab_focus()


func resume_game() -> void:
	get_tree().paused = false
	hide()


func _on_resume_pressed() -> void:
	resume_game()

func _on_quit_pressed() -> void:
	GameManager.save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")


func _on_settings_pressed() -> void:
	var settings: Control = preload("res://scenes/settings.tscn").instantiate()
	settings.opened_from_pause_menu = true
	settings.closed.connect(_on_settings_closed)   # <-- drives the reopen
	add_child(settings)                            # child of the pause menu

	settings_open = true
	$Panel.hide()                                  # <-- kills Tab access to these buttons
	# NOTE: no settings.scale here — it inherits this node's 0.4 scale


func _on_settings_closed() -> void:
	settings_open = false
	$Panel.show()
	resume_button.grab_focus()
