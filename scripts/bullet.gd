extends Area2D

const SPEED := 600.0
var damage: int = 20

var direction := Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta

func _on_body_entered(body: Node) -> void:
	print("Bullet hit: ", body.name)
	print("Bullet collided with: ", body.name)
	print("Is Enemy: ", body is Enemy)
	print("Damage: ", damage)
	if body is Enemy:
		print("Enemy hit! Damage: ", damage)
		body.take_damage(damage, global_position)

	queue_free()
