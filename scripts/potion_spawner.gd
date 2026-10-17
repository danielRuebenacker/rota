class_name PotionSpawner
extends Node

@export var potion_scene: PackedScene
@export var player_path: NodePath
@export var bounds := Rect2(-1800, -1800, 3600, 3600)
@export var check_interval := 8.0
@export_range(0.0, 1.0, 0.01) var spawn_chance := 0.15
@export var max_active_potions := 2
@export var player_safe_radius := 180.0

var rng := RandomNumberGenerator.new()
var check_accumulator := 0.0

@onready var player: Node2D = get_node_or_null(player_path)

func _ready() -> void:
	rng.randomize()

func _process(delta: float) -> void:
	check_accumulator += delta
	if check_accumulator < check_interval:
		return
	check_accumulator = 0.0

	if get_tree().get_nodes_in_group("HealingPotion").size() >= max_active_potions:
		return
	if rng.randf() > spawn_chance:
		return
	_spawn_potion()

func _spawn_potion() -> void:
	if potion_scene == null:
		return

	var potion_position: Variant = _get_spawn_position()
	if potion_position == null:
		return

	var potion := potion_scene.instantiate()
	potion.position = potion_position
	get_parent().add_child(potion)

func _get_spawn_position() -> Variant:
	for _attempt in range(12):
		var candidate := Vector2(
			rng.randf_range(bounds.position.x, bounds.end.x),
			rng.randf_range(bounds.position.y, bounds.end.y)
		)
		if not is_instance_valid(player) or candidate.distance_to(player.global_position) >= player_safe_radius:
			return candidate
	return null
