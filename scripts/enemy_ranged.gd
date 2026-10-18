extends Enemy

@export var player: Player

@export var speed: float = 100.0
@export var preferred_distance: float = 250.0
@export var distance_tolerance: float = 30.0

@export var fire_interval: float = 1.5
@export var projectile_scene: PackedScene

var fire_timer: float = 0.0


func update_behaviour(delta: float) -> void:
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	if player.is_dead:
		velocity = Vector2.ZERO
		return

	# Face the player
	var direction := global_position.direction_to(player.global_position)
	var distance := global_position.distance_to(player.global_position)

	rotation = direction.angle()

	# Maintain distance from the player
	if distance < preferred_distance - distance_tolerance:
		velocity = -direction * speed

	elif distance > preferred_distance + distance_tolerance:
		velocity = direction * speed

	else:
		velocity = Vector2.ZERO

	# Fire at the player
	fire_timer -= delta

	if fire_timer <= 0.0:
		shoot()
		fire_timer = fire_interval


@onready var muzzle: Marker2D = $Marker2D

func shoot() -> void:
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate() as Area2D

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = muzzle.global_position
	projectile.global_rotation = global_rotation
