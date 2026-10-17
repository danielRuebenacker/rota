extends Area2D

const SPEED := 600.0

var direction := Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		return
	if body.is_in_group("Enemy"):
		body.queue_free()  # or call body.take_damage() if you have one
	if body.is_in_group("Wall"):
		print("Hit Wall")
	# Hit an enemy or wall: the bullet is spent
	queue_free()
