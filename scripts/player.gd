class_name Player
extends CharacterBody2D

signal health_changed

const SPEED = 300.0

@export var max_health = 200
@onready var current_health: int = max_health 

@onready var weapon_holder: Node2D = $WeaponHolder

var current_weapon: Node2D

func _ready() -> void:
	add_to_group("Player")
	health_changed.emit()

func get_player_direction() -> Vector2:
	return Vector2.RIGHT.rotated(rotation)
	
	
var _can_be_hit := true
func take_damage(amount: int) -> void:
	if not _can_be_hit:
		return
	_can_be_hit = false
	current_health = max(current_health - amount, 0)
	health_changed.emit()
	if current_health <= 0:
		die()
		return
	await get_tree().create_timer(0.5).timeout
	_can_be_hit = true
		
# player killed
func die() -> void:
	queue_free()

func equip_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon != null:
		current_weapon.queue_free()

	current_weapon = weapon_scene.instantiate() as Node2D
	weapon_holder.add_child(current_weapon)
	current_weapon.position = Vector2.ZERO

func _physics_process(delta: float) -> void:
		
	if Input.is_action_pressed("use") and current_weapon != null:
		current_weapon.use()
		
	if Input.is_action_pressed("ui_right"):
		rotation += 5.0 * delta
		
	var forward_direction := get_player_direction()
	velocity = forward_direction * SPEED


	move_and_slide()
	
	# Object Collison script
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider == null or collider.is_queued_for_deletion():
			continue
		
		if collider.is_in_group("GameWall"):
			print("Hit a wall named: ", collider.name)
			# gets rid of player
			# queue_free()
			return
		elif collider.is_in_group("Loot"):
			print("Hit loot named: ", collider.name)
			# gets rid of loot
			collider.queue_free()
			# queue free breaks references to player -- make death different
		elif collider is Enemy:
			take_damage(10)
