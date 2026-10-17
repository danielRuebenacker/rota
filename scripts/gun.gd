class_name Gun
extends Item

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
@export var fire_cooldown := 0.25
@export var damage := 10

var _can_fire := true

func use() -> void:
	if not _can_fire:
		return
	_can_fire = false

	var bullet := BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)

	var muzzle := get_node_or_null("Muzzle") as Marker2D
	bullet.global_position = muzzle.global_position if muzzle else global_position
	bullet.direction = global_transform.x.normalized()
	bullet.rotation = global_rotation
	bullet.damage = damage

	await get_tree().create_timer(fire_cooldown).timeout
	_can_fire = true
