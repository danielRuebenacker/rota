extends Node2D

signal change_item_pulse

@export var pulse_interval: float = 2.0

@onready var wheel = $ItemWheel/Polygon2D
@onready var player = $Player
@onready var timer: Timer = $ItemTimer


func _ready() -> void:
	change_item_pulse.connect(wheel.pulse_rotation)
	change_item_pulse.connect(update_player_weapon)

	timer.wait_time = pulse_interval
	timer.timeout.connect(func(): change_item_pulse.emit())
	timer.start()

	update_player_weapon()


func update_player_weapon() -> void:
	var item_scene = wheel.get_current_item()

	if item_scene != null:
		player.equip_weapon(item_scene)
		
