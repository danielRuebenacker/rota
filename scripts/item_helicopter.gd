extends Item

@export var cooldown := 4.0
var can_use := true

func use() -> void:
	if not can_use:
		return

	var player := get_parent().get_parent() as Player
	if player == null or player.is_dead or player.is_helicoptering:
		return

	can_use = false
	player.helicopter_lift()
	await get_tree().create_timer(cooldown).timeout
	can_use = true
