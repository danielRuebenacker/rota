class_name WaveManager
extends Node

signal wave_started(wave: int)
signal wave_completed(wave: int)

@export var enemy_spawner: EnemySpawner
@export var starting_enemy_count: int = 8
@export var enemies_added_per_wave: int = 4

var current_wave := 0
var wave_active := false

@export var unlockable_items: Array[PackedScene]

var unlocked_items: Array[PackedScene] = []


func _ready() -> void:
	start_next_wave()


func _process(_delta: float) -> void:
	if not wave_active:
		return

	# wait until all enemies have spawned
	if enemy_spawner.wave_active:
		return

	# wait until all remaining enemies are defeated
	if get_tree().get_nodes_in_group("Enemy").size() > 0:
		return

	complete_wave()


func start_next_wave() -> void:
	current_wave += 1
	wave_active = true

	var enemy_count := (
		starting_enemy_count
		+ (current_wave - 1) * enemies_added_per_wave
	)

	enemy_spawner.start_wave(enemy_count)

	wave_started.emit(current_wave)


func complete_wave() -> void:
	wave_active = false

	var new_item := unlock_random_item()
	wave_completed.emit(current_wave)


func unlock_random_item() -> PackedScene:
	var locked_items: Array[PackedScene] = []

	for item in unlockable_items:
		if not unlocked_items.has(item):
			locked_items.append(item)

	if locked_items.is_empty():
		return null

	var new_item : PackedScene = locked_items.pick_random()
	unlocked_items.append(new_item)

	return new_item
