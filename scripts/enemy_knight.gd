extends Enemy

const SPEED := 100.0
const SWORD_DAMAGE := 20

@export var player: Player

@export var attack_range: float = 120.0
@export var attack_windup: float = 0.4
@export var attack_cooldown: float = 1.0
@export var attack_arc: float = 160.0
@export var swing_duration: float = 0.35

@export var attack_recoil: float = 1200.0
@export var recoil_recovery: float = 2500.0

enum State {
	CHASE,
	WINDUP,
	ATTACK,
	COOLDOWN
}

var state := State.CHASE
var state_timer := 0.0
var hit_player := false

var hit_bodies: Array[Node2D] = []

@onready var sword: Node2D = $Sword
@onready var sword_hitbox: Area2D = $Sword/Hitbox


func _ready() -> void:
	super._ready()
	sword_hitbox.monitoring = false


func update_behaviour(delta: float) -> void:
	if not is_instance_valid(player) or player.is_dead:
		velocity = Vector2.ZERO
		return

	var direction := global_position.direction_to(player.global_position)
	var distance := global_position.distance_to(player.global_position)

	state_timer -= delta

	match state:
		State.CHASE:
			rotation = direction.angle()

			if distance > attack_range:
				velocity = direction * SPEED
			else:
				velocity = Vector2.ZERO
				state = State.WINDUP
				state_timer = attack_windup

		State.WINDUP:
			velocity = Vector2.ZERO

			if state_timer <= 0.0:
				state = State.ATTACK
				swing_sword()

		State.ATTACK:
			velocity = Vector2.ZERO
			check_sword_hits()

		State.COOLDOWN:
			velocity = Vector2.ZERO

			if state_timer <= 0.0:
				state = State.CHASE


func swing_sword() -> void:
	hit_player = false
	hit_bodies.clear()

	sword.rotation_degrees = -attack_arc / 2.0
	sword_hitbox.monitoring = true

	var tween := create_tween()

	tween.tween_property(
		sword,
		"rotation_degrees",
		attack_arc / 2.0,
		swing_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	sword_hitbox.monitoring = false

	state = State.COOLDOWN
	state_timer = attack_cooldown


func check_sword_hits() -> void:
	for body in sword_hitbox.get_overlapping_bodies():
		if body in hit_bodies:
			continue

		if body is Player:
			if body.is_dead:
				continue

			body.take_damage(SWORD_DAMAGE)
			hit_bodies.append(body)
			hit_player = true

			# Knock back immediately on hit
			recoil()


func recoil() -> void:
	if not is_instance_valid(player):
		return

	knockback_velocity = (global_position - player.global_position).normalized() * attack_recoil


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if knockback_velocity.length() > 0.0:
		knockback_velocity = knockback_velocity.move_toward(
			Vector2.ZERO,
			maxf(recoil_recovery - 600.0, 0.0) * delta
		)
