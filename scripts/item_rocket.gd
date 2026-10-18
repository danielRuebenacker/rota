extends Item

@export var cooldown: float = 3.0

@onready var particles: GPUParticles2D = $GPUParticles2D

var can_use := true


func use() -> void:
	if not can_use:
		return

	var player := get_parent().get_parent() as Player

	if player == null or player.is_dead or player.is_boosting:
		return

	can_use = false
	player.boost()

	particles.emitting = true

	await get_tree().create_timer(player.boost_duration).timeout
	particles.emitting = false

	await get_tree().create_timer(
		maxf(cooldown - player.boost_duration, 0.0)
	).timeout

	can_use = true
