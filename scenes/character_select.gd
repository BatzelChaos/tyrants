extends Control

@onready var start_button: Button = $VBoxContainer2/start

@onready var kaniel_button: Button = $VBoxContainer/HBoxContainer/kaniel
@onready var biene_button: Button = $VBoxContainer/HBoxContainer/biene
@onready var avanch_button: Button = $VBoxContainer/HBoxContainer2/avanch
@onready var cro_button: Button = $VBoxContainer/HBoxContainer2/cro

var _character_group := ButtonGroup.new()


func _ready() -> void:
	for button in [kaniel_button, biene_button, avanch_button, cro_button]:
		button.toggle_mode = true
		button.button_group = _character_group
	start_button.disabled = true


func _on_kaniel_pressed() -> void:
	_pick("kaniel")


func _on_biene_pressed() -> void:
	_pick("biene")


func _on_avanch_pressed() -> void:
	_pick("avanch")


func _on_cro_pressed() -> void:
	_pick("cro")


func _pick(id: String) -> void:
	GameManager.select_character(id)
	start_button.disabled = false


func _on_start_pressed() -> void:
	GameManager.start_game(false)
