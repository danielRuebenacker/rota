extends Node2D

@export var damage: int = 80
@export var fuse_time := 0.8
@export var blast_radius := 150.0
@export var throw_distance := 120.0
@export var throw_duration := 0.25

var direction := Vector2.RIGHT

@onready var grenade_sprite: Sprite2D = $Sprite2D
@onready var explosion: Polygon2D = $Explosion

func _ready() -> void:
	explosion.visible = false
	var throw_tween := create_tween()
	throw_tween.tween_property(
		self,
		"global_position",
		global_position + direction * throw_distance,
		throw_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await throw_tween.finished
	await get_tree().create_timer(fuse_time).timeout
	_explode()

func _explode() -> void:
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy.global_position.distance_to(global_position) <= blast_radius:
			enemy.take_damage(damage)

	grenade_sprite.visible = false
	explosion.visible = true
	explosion.scale = Vector2.ZERO
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(explosion, "scale", Vector2.ONE, 0.25)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)
