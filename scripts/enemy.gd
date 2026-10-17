class_name Enemy
extends CharacterBody2D

signal health_changed

@export var max_health := 200

var health: int
var level := 1
var _base_max_health: int

func _ready() -> void:
	# Set here so an inspector-edited max_health is respected
	_base_max_health = max_health
	max_health = get_scaled_max_health()
	health = max_health
	add_to_group("Enemy")
	health_changed.emit()

func set_level(new_level: int) -> void:
	level = max(new_level, 1)
	if is_inside_tree():
		max_health = get_scaled_max_health()
		health = max_health
		health_changed.emit()

func get_scaled_max_health() -> int:
	var base_health := _base_max_health if _base_max_health > 0 else max_health
	return int(round(base_health * pow(1.2, level - 1)))

func take_damage(damage: int) -> void:
	health = max(health - damage, 0)
	health_changed.emit()
	if health <= 0:
		die()

func die() -> void:
	queue_free()
