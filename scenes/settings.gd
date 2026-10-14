extends Control

const SETTINGS_PATH := "user://settings.cfg"

@onready var fullscreen_check: CheckButton = $Panel/MarginContainer/VBoxContainer/FullscreenCheck
@onready var vsync_check: CheckButton = $Panel/MarginContainer/VBoxContainer/VSyncCheck
@onready var volume_label: Label = $Panel/MarginContainer/VBoxContainer/VolumeRow/VolumeLabel
@onready var volume_slider: HSlider = $Panel/MarginContainer/VBoxContainer/VolumeRow/VolumeSlider
@onready var back_button: Button = $Panel/MarginContainer/VBoxContainer/BackButton


func _ready() -> void:
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	back_button.pressed.connect(_on_back_pressed)

	_load_settings()


func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED


func _on_vsync_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_volume_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	# linear_to_db(0.0) is -inf, so clamp near-silence to a very low value
	var db := linear_to_db(maxf(value, 0.0001))
	AudioServer.set_bus_volume_db(bus, db)
	volume_label.text = "Volume: %d%%" % roundi(value * 100)


func _on_back_pressed() -> void:
	_save_settings()
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")


# --- Persistence ------------------------------------------------------------

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", fullscreen_check.button_pressed)
	cfg.set_value("video", "vsync", vsync_check.button_pressed)
	cfg.set_value("audio", "volume", volume_slider.value)
	cfg.save(SETTINGS_PATH)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)  # missing file is fine; get_value() falls back to defaults

	# Assigning these fires the signals connected in _ready, which applies them.
	fullscreen_check.button_pressed = cfg.get_value("video", "fullscreen", false)
	vsync_check.button_pressed = cfg.get_value("video", "vsync", true)
	volume_slider.value = cfg.get_value("audio", "volume", 1.0)
