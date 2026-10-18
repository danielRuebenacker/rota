class_name WaveCompleteMenu
extends Control

@export var wave_manager: WaveManager

@onready var continue_button: Button = $PanelContainer/VBoxContainer/ContinueButton


func _ready() -> void:
	hide()
	continue_button.pressed.connect(_on_continue_pressed)


func show_menu() -> void:
	show()
	get_tree().paused = true


func _on_continue_pressed() -> void:
	hide()
	get_tree().paused = false
	wave_manager.start_next_wave()
