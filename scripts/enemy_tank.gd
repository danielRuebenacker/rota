extends Enemy

const SPEED := 55.0
const CONTACT_DAMAGE := 35

@export var player: Player

@export var charge_range: float = 250.0
@export var charge_speed: float = 350.0
@export var charge_windup: float = 0.8
@export var charge_duration: float = 0.6
@export var charge_cooldown: float = 2.0

@export var attack_recoil: float = 600.0
@export var recoil_recovery: float = 2500.0

@export var shake_amount: float = 4.0
@export var afterimage_interval: float = 0.05

enum State {
	CHASE,
	WINDUP,
	CHARGE,
	COOLDOWN
}

var state := State.CHASE
var state_timer := 0.0
var charge_direction := Vector2.ZERO
var hit_player := false

var windup_elapsed := 0.0
var afterimage_timer := 0.0
var original_sprite_position := Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	super._ready()
	original_sprite_position = sprite.position


func update_behaviour(delta: float) -> void:
	if not is_instance_valid(player) or player.is_dead:
		velocity = Vector2.ZERO
		reset_visuals()
		return

	var direction := global_position.direction_to(player.global_position)
	var distance := global_position.distance_to(player.global_position)

	state_timer -= delta

	match state:
		State.CHASE:
			rotation = direction.angle()
			velocity = direction * SPEED

			if distance <= charge_range:
				state = State.WINDUP
				state_timer = charge_windup
				windup_elapsed = 0.0
				velocity = Vector2.ZERO

		State.WINDUP:
			velocity = Vector2.ZERO
			windup_elapsed += delta

			var progress := clampf(
				1.0 - state_timer / maxf(charge_windup, 0.001),
				0.0,
				1.0
			)

			# flash white when charging
			var flash_speed := lerpf(8.0, 35.0, progress)
			var flash_amount := (sin(windup_elapsed * flash_speed) + 1.0) / 2.0

			sprite.modulate = Color.WHITE

			sprite.self_modulate = Color.WHITE.lerp(
				Color(2.0, 2.0, 2.0, 1.0),
				flash_amount
			)

			# shake
			sprite.position = original_sprite_position + Vector2(
				randf_range(-shake_amount, shake_amount),
				randf_range(-shake_amount, shake_amount)
			) * progress

			if state_timer <= 0.0:
				reset_visuals()

				charge_direction = global_position.direction_to(player.global_position)

				rotation = charge_direction.angle()
				hit_player = false
				afterimage_timer = 0.0

				state = State.CHARGE
				state_timer = charge_duration

		State.CHARGE:
			velocity = charge_direction * charge_speed

			afterimage_timer -= delta

			if afterimage_timer <= 0.0:
				spawn_afterimage()
				afterimage_timer = afterimage_interval

			if state_timer <= 0.0:
				state = State.COOLDOWN
				state_timer = charge_cooldown
				velocity = Vector2.ZERO
				reset_visuals()

		State.COOLDOWN:
			velocity = Vector2.ZERO

			if state_timer <= 0.0:
				state = State.CHASE


func check_collisions() -> void:
	if state != State.CHARGE or hit_player:
		return

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider == null or collider.is_queued_for_deletion():
			continue

		if collider is Player:
			collider.take_damage(CONTACT_DAMAGE)
			hit_player = true

			state = State.COOLDOWN
			state_timer = charge_cooldown
			reset_visuals()

			
			recoil()
			break

func recoil() -> void:
	if not is_instance_valid(player):
		return

	var direction := -charge_direction

	global_position += direction * 30.0

	knockback_velocity = direction * attack_recoil
	velocity = knockback_velocity


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		maxf(recoil_recovery - 600.0, 0.0) * delta
	)


func reset_visuals() -> void:
	sprite.modulate = Color.WHITE
	sprite.self_modulate = Color.WHITE
	sprite.position = original_sprite_position


# this is for like the ghost trail when dashing towards player
func spawn_afterimage() -> void:
	var ghost := Sprite2D.new()

	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.scale = sprite.global_scale
	ghost.global_rotation = sprite.global_rotation
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.4)

	get_tree().current_scene.add_child(ghost)
	ghost.global_position = sprite.global_position

	# fade alpha value
	var tween := ghost.create_tween()
	tween.tween_property(
		ghost,
		"modulate:a",
		0.0,
		0.2
	)
	tween.tween_callback(ghost.queue_free)
