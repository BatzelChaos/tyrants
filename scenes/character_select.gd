extends Control

@onready var start_button: Button = $VBoxContainer2/start


func _ready() -> void:
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
