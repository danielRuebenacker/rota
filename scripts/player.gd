extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta: float) -> void:
		
	if Input.is_action_pressed("ui_right"):
		rotation += 5.0 * delta
		
	var forward_direction := Vector2.RIGHT.rotated(rotation)
	velocity = forward_direction * SPEED


	move_and_slide()
