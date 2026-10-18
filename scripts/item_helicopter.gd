extends Item

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const BURST_COUNT := 12
const BURST_DAMAGE := 8
const BURST_INTERVAL := 0.3

@export var cooldown := 4.0
var can_use := true

func use() -> void:
	if not can_use:
		return

	var player := get_tree().current_scene.get_node_or_null("Player") as Player
	if player == null or player.is_dead or player.is_helicoptering:
		return

	can_use = false
	player.helicopter_lift()
	fire_bursts(player)
	await get_tree().create_timer(cooldown).timeout
	can_use = true

func fire_bursts(player: Player) -> void:
	_fire_burst(player)
	await get_tree().create_timer(BURST_INTERVAL).timeout
	if is_instance_valid(player) and player.is_helicoptering:
		_fire_burst(player)

func _fire_burst(player: Player) -> void:
	var scene := get_tree().current_scene
	for index in range(BURST_COUNT):
		var bullet := BULLET_SCENE.instantiate()
		scene.add_child(bullet)
		bullet.global_position = player.global_position
		bullet.direction = Vector2.RIGHT.rotated(TAU * index / BURST_COUNT)
		bullet.rotation = bullet.direction.angle()
		bullet.damage = BURST_DAMAGE
