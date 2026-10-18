extends Item

@export var cooldown := 4.0
var can_use := true
@export var player: Player

func use() -> void:
	if not can_use:
		return

	var owner_player := player
	if owner_player == null:
		owner_player = get_parent().get_parent() as Player
	if owner_player == null or owner_player.is_dead or owner_player.is_helicoptering:
		return

	can_use = false
	owner_player.helicopter_lift()
	await get_tree().create_timer(cooldown).timeout
	can_use = true
