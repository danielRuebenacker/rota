class_name Player
extends CharacterBody2D

signal health_changed

const SPEED = 250.0
const TURN_SPEED = 7.0

@export var max_health = 200
@onready var current_health: float = max_health

@onready var weapon_holder: Node2D = $WeaponHolder
var is_dead: bool = false
var current_weapon: Node2D

@export var boost_speed: float = 600.0
@export var boost_duration: float = 0.4

var is_boosting := false
var boost_direction := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var trail_timer := 0.0

var damage_tween: Tween

@onready var camera: Camera2D = $Camera2D
@export var shake_strength: float = 8.0
@export var shake_duration: float = 0.2

@export var arrow_distance: float = 40.0
@export var arrow_length: float = 25.0
@export var arrow_color: Color = Color.WHITE

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
	
	damage_effect()
	
	if current_health <= 0:
		die()
		return
	await get_tree().create_timer(0.5).timeout
	_can_be_hit = true

func heal_percent(percent: float) -> void:
	current_health = min(current_health + max_health * percent, max_health)
	health_changed.emit()
		
# player killed
func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	var death_screen = get_node("/root/Game/DeathScreen")
	death_screen.visible = true

func equip_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon != null:
		current_weapon.queue_free()

	current_weapon = weapon_scene.instantiate() as Node2D
	weapon_holder.add_child(current_weapon)
	current_weapon.position = Vector2.ZERO

func _physics_process(delta: float) -> void:
		
	if Input.is_action_pressed("use") and current_weapon != null:
		current_weapon.use()
	#rotation = (get_global_mouse_position() - global_position).angle()
	
	if Input.is_action_pressed("ui_right"):
		rotation += TURN_SPEED * delta
		
	if is_boosting:
		velocity = boost_direction * boost_speed
	else:
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
			take_damage(40)
			# gets rid of player
			# queue_free()
			return
		elif collider.is_in_group("Loot"):
			print("Hit loot named: ", collider.name)
			if collider.has_method("heal_player"):
				collider.heal_player(self)
			if collider.has_method("get_pickup_scene"):
				var weapon_scene: PackedScene = collider.get_pickup_scene()
				var game := get_tree().current_scene
				if weapon_scene != null and game.has_method("collect_weapon"):
					game.collect_weapon(weapon_scene)
			# gets rid of loot
			collider.queue_free()
			# queue free breaks references to player -- make death different


func boost() -> void:
	if is_boosting or is_dead:
		return

	is_boosting = true
	boost_direction = get_player_direction()
	await get_tree().create_timer(boost_duration).timeout
	is_boosting = false
	
	


func _draw() -> void:
	var start := Vector2.RIGHT * arrow_distance
	var end := start + Vector2.RIGHT * arrow_length

	
	draw_line(start, end, arrow_color, 3.0)

	var arrow_size := 8.0

	draw_line(end,end + Vector2(-arrow_size, -arrow_size),arrow_color,3.0)

	draw_line(end,end + Vector2(-arrow_size, arrow_size),arrow_color,3.0)

func damage_effect() -> void:
	shake_camera()
	if damage_tween and damage_tween.is_running():
		damage_tween.kill()

	sprite.modulate = Color.RED

	damage_tween = create_tween()
	damage_tween.tween_property(
		sprite,
		"modulate",
		Color.WHITE,
		0.3
	)
	
	
	
func shake_camera() -> void:
	var tween := create_tween()

	for i in range(6):
		tween.tween_property(
			camera,
			"offset",
			Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			),
			shake_duration / 6.0
		)

	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
