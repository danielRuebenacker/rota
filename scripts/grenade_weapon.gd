extends Item

const GRENADE_SCENE := preload("res://scenes/grenade.tscn")

@export var damage: int = 80
@export var cooldown := 2.0
@export var drop_distance := 48.0

var _can_throw := true

func use() -> void:
	if not _can_throw:
		return
	_can_throw = false

	var grenade := GRENADE_SCENE.instantiate()
	get_tree().current_scene.add_child(grenade)
	grenade.global_position = global_position
	grenade.direction = global_transform.x.normalized()
	grenade.damage = damage

	await get_tree().create_timer(cooldown).timeout
	_can_throw = true
