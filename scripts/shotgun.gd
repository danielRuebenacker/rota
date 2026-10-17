extends Gun

@export var pellet_count := 5
@export var spread_degrees := 24.0

func use() -> void:
	if not _can_fire:
		return
	_can_fire = false

	var muzzle := get_node_or_null("Muzzle") as Marker2D
	var muzzle_position := muzzle.global_position if muzzle else global_position
	var forward := global_transform.x.normalized()

	for i in range(pellet_count):
		var bullet := BULLET_SCENE.instantiate()
		get_tree().current_scene.add_child(bullet)
		var fraction := float(i) / float(max(pellet_count - 1, 1)) - 0.5
		bullet.global_position = muzzle_position
		bullet.direction = forward.rotated(deg_to_rad(fraction * spread_degrees))
		bullet.rotation = bullet.direction.angle()
		bullet.damage = damage

	await get_tree().create_timer(fire_cooldown).timeout
	_can_fire = true
