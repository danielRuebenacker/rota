extends Area2D

@export var heal_percent: float = 0.05
@export var heal_interval: float = 0.5
@export var duration: float = 5.0

var elapsed := 0.0
var heal_timer := 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	z_index = -1
	monitoring = true

	# Detect all collision layers temporarily
	collision_mask = 0xFFFFFFFF

	animate_cloud()


func _physics_process(delta: float) -> void:
	elapsed += delta
	heal_timer += delta

	if heal_timer >= heal_interval:
		heal_timer -= heal_interval

		for body in get_overlapping_bodies():
			print("Cloud detected: ", body.name)

			if body is Player or body is Enemy:
				if body is Player and body.is_dead:
					continue

				print("Healing: ", body.name)
				body.heal_percent(heal_percent)

	# Fade during the last second
	if elapsed >= duration - 1.0:
		sprite.modulate.a = clampf(duration - elapsed, 0.0, 1.0)

	if elapsed >= duration:
		queue_free()


func animate_cloud() -> void:
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		sprite,
		"scale",
		Vector2(1.1, 1.1),
		0.8
	)

	tween.tween_property(
		sprite,
		"scale",
		Vector2(0.9, 0.9),
		0.8
	)
