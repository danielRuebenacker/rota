class_name Enemy
extends CharacterBody2D

signal health_changed

@export var max_health := 160
@export var knockback_strength := 200.0

var health: int
var level := 1
var _base_max_health: int

var knockback_velocity := Vector2.ZERO
var flash_tween: Tween


func _ready() -> void:
	# Set here so an inspector-edited max_health is respected
	_base_max_health = max_health
	max_health = get_scaled_max_health()
	health = max_health
	add_to_group("Enemy")
	health_changed.emit()


func _physics_process(delta: float) -> void:
	update_behaviour(delta)

	velocity += knockback_velocity
	move_and_slide()

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO, 600.0 * delta
	)

	check_collisions()


# Override this for different enemy types
func update_behaviour(_delta: float) -> void:
	velocity = Vector2.ZERO


# Override this if the enemy needs collision behaviour
func check_collisions() -> void:
	pass


func set_level(new_level: int) -> void:
	level = max(new_level, 1)
	if is_inside_tree():
		max_health = get_scaled_max_health()
		health = max_health
		health_changed.emit()


func get_scaled_max_health() -> int:
	var base_health := _base_max_health if _base_max_health > 0 else max_health
	return int(round(base_health * pow(1.2, level - 1)))


func take_damage(damage: int, source_position: Vector2 = Vector2.INF) -> void:
	health = max(health - damage, 0)
	health_changed.emit()

	# Knockback
	if source_position.is_finite():
		knockback_velocity = (
			global_position - source_position
		).normalized() * knockback_strength

	# Flash red when hit
	var sprite := get_node_or_null("Sprite2D") as Sprite2D

	if sprite:
		if flash_tween and flash_tween.is_running():
			flash_tween.kill()

		sprite.modulate = Color.RED

		flash_tween = create_tween()
		flash_tween.tween_property(
			sprite,
			"modulate",
			Color.WHITE,
			0.15
		)

	if health <= 0:
		die()


func die() -> void:
	var game := get_tree().current_scene
	if game != null and game.has_method("spawn_enemy_drop"):
		game.spawn_enemy_drop(global_position)
	queue_free()
	
	
func heal_percent(percent: float) -> void:
	health = mini(health + int(max_health * percent), max_health)
	health_changed.emit()
