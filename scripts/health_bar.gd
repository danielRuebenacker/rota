extends ProgressBar

@export var player: Player

func _ready() -> void:
	if player == null:
		push_warning("HealthBar requires a Player reference")
		return
	player.health_changed.connect(update)
	update()

func update() -> void:
	if is_instance_valid(player):
		value = player.current_health * 100.0 / player.max_health
