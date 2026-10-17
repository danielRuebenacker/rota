extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:

	# Handle jump.
	if Input.is_action_just_pressed("use"):
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("ui_right"):
		rotation += 5.0 * delta


	move_and_slide()
