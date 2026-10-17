extends Area2D

const SPEED := 600.0
const DAMAGE := 10

var direction := Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta

func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		body.take_damage(DAMAGE)

	# Hit an enemy or a wall: the bullet is spent
	queue_free()
