class_name Enemy
extends CharacterBody2D

@export var max_health := 200

var health: int

func _ready() -> void:
	# Set here so an inspector-edited max_health is respected
	health = max_health

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	queue_free()
