class_name Enemy
extends CharacterBody2D

signal health_changed

@export var max_health := 200

var health: int

func _ready() -> void:
	# Set here so an inspector-edited max_health is respected
	health = max_health
	health_changed.emit()

func take_damage(damage: int) -> void:
	health = max(health - damage, 0)
	health_changed.emit()
	if health <= 0:
		die()

func die() -> void:
	queue_free()
