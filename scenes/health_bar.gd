extends ProgressBar

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_changed.connect(update)
	update()

func update():
	value = player.current_health * 100 / player.max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
