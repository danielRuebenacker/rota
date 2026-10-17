extends CharacterBody2D

const SPEED = 300.0


func _physics_process(delta: float) -> void:
		
	if Input.is_action_pressed("ui_right"):
		rotation += 5.0 * delta
		
	var forward_direction := Vector2.RIGHT.rotated(rotation)
	velocity = forward_direction * SPEED


	move_and_slide()
	
	# Object Collison script
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		print("Hit: ", collider.name, " groups: ", collider.get_groups())
		if collider.is_in_group("GameWall"):
			print("Hit a wall named: ", collider.name)
			# kills the player
			queue_free()
			return
