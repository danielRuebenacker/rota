extends Area2D

@export var damage_percent: float = 0.05
@export var damage_interval: float = 0.5
@export var duration: float = 5.0

var elapsed := 0.0
var damage_timer := 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	z_index = -1
	monitoring = true

	# Detect all collision layers temporarily
	collision_mask = 0xFFFFFFFF

	animate_cloud()


func _physics_process(delta: float) -> void:
	elapsed += delta
	damage_timer += delta

	if damage_timer >= damage_interval:
		damage_timer -= damage_interval

		for body in get_overlapping_bodies():
			if body is Player or body is Enemy:
				if body is Player and body.is_dead:
					continue

				var damage := int(body.max_health * damage_percent)
				body.take_damage(damage)

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
