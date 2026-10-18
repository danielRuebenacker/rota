class_name EnemySpawner
extends Node

@export var enemy_scene: PackedScene
@export var ranged_enemy_scene: PackedScene
@export_range(0.0, 1.0) var ranged_spawn_chance := 0.1
@export var knight_enemy_scene: PackedScene
@export_range(0.0, 1.0) var knight_spawn_chance := 0.025
@export var tank_enemy_scene: PackedScene
@export_range(0.0, 1.0) var tank_spawn_chance := 1.0

@export var player_path: NodePath
@export var bounds := Rect2(-1900, -1900, 3800, 3800)
@export var starting_interval := 4.0
@export var minimum_interval := 0.6
@export var interval_decrease := 0.08
@export var level_interval := 30.0

const MAX_ENEMIES := 20

@export var spawn_margin := 100.0
@export var player_safe_radius := 500.0

var elapsed_time := 0.0
var spawn_accumulator := 0.0
var rng := RandomNumberGenerator.new()

@onready var player: Node2D = get_node_or_null(player_path)

var wave_active := false
var wave_spawn_limit := 0
var wave_spawned := 0

func start_wave(enemy_count: int) -> void:
	wave_spawn_limit = enemy_count
	wave_spawned = 0
	spawn_accumulator = 0.0
	wave_active = true


func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	if not wave_active:
		return
	
	elapsed_time += delta
	spawn_accumulator += delta

	var interval: float = maxf(
		minimum_interval,
		starting_interval - elapsed_time * interval_decrease
	)

	while spawn_accumulator >= interval and wave_spawned < wave_spawn_limit:
		spawn_accumulator -= interval
		if _active_enemy_count() >= MAX_ENEMIES:
			break	
		if _spawn_enemy():
			wave_spawned += 1
	if wave_spawned >= wave_spawn_limit:
		wave_active = false


func _active_enemy_count() -> int:
	return get_tree().get_nodes_in_group("Enemy").size()


func _spawn_enemy() -> bool:
	if enemy_scene == null or _active_enemy_count() >= MAX_ENEMIES:
		return false

	var spawn_position: Variant = _get_spawn_position()
	if spawn_position == null:
		return false

	# Choose which enemy to spawn
	var selected_scene: PackedScene = enemy_scene
	var roll := rng.randf()

	if tank_enemy_scene != null and roll < tank_spawn_chance:
		selected_scene = tank_enemy_scene
	elif knight_enemy_scene != null and roll < tank_spawn_chance + knight_spawn_chance:
		selected_scene = knight_enemy_scene
	elif ranged_enemy_scene != null and roll < tank_spawn_chance + knight_spawn_chance + ranged_spawn_chance:
		selected_scene = ranged_enemy_scene
	var enemy := selected_scene.instantiate() as Enemy

	if enemy == null:
		push_warning("EnemySpawner scene must instantiate an Enemy")
		return false

	enemy.level = 1 + int(elapsed_time / level_interval)
	enemy.position = spawn_position as Vector2
	enemy.set("player", player)

	get_parent().add_child(enemy)
	return true


func _get_spawn_position() -> Variant:
	var inner_bounds: Rect2 = bounds.grow(-spawn_margin)
	var candidate := Vector2.ZERO

	for _attempt in range(12):
		var side := rng.randi_range(0, 3)

		if side == 0:
			candidate = Vector2(
				rng.randf_range(inner_bounds.position.x, inner_bounds.end.x),
				inner_bounds.position.y
			)
		elif side == 1:
			candidate = Vector2(
				inner_bounds.end.x,
				rng.randf_range(inner_bounds.position.y, inner_bounds.end.y)
			)
		elif side == 2:
			candidate = Vector2(
				rng.randf_range(inner_bounds.position.x, inner_bounds.end.x),
				inner_bounds.end.y
			)
		else:
			candidate = Vector2(
				inner_bounds.position.x,
				rng.randf_range(inner_bounds.position.y, inner_bounds.end.y)
			)

		if not is_instance_valid(player) or candidate.distance_to(player.global_position) >= player_safe_radius:
			return candidate

	return null
