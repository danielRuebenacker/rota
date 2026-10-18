extends Area2D

@export var speed: float = 350.0
@export var damage: int = 10
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	body_entered.connect(on_body_entered)

	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += direction.rotated(rotation) * speed * delta


func on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
		queue_free()

	elif body.is_in_group("GameWall"):
		queue_free()
