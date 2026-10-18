class_name WaveManager
extends Node

signal wave_started(wave: int)
signal wave_completed(wave: int)

@export var enemy_spawner: EnemySpawner
@export var wave_complete_menu: Control

@export var starting_enemy_count: int = 7
@export var enemies_added_per_wave: int = 4

var current_wave := 0
var wave_active := false


func _ready() -> void:
	start_next_wave()


func _process(_delta: float) -> void:
	if not wave_active:
		return

	# Wait until all enemies have spawned
	if enemy_spawner.wave_spawned < enemy_spawner.wave_spawn_limit:
		return

	# Wait until all enemies have died
	if get_tree().get_nodes_in_group("Enemy").size() > 0:
		return

	complete_wave()


func start_next_wave() -> void:
	current_wave += 1
	wave_active = true

	var enemy_count: int = (
		starting_enemy_count
		+ (current_wave - 1) * enemies_added_per_wave
	)

	enemy_spawner.start_wave(enemy_count)

	wave_started.emit(current_wave)

	print("Starting wave ", current_wave)


func complete_wave() -> void:
	wave_active = false

	wave_completed.emit(current_wave)

	print("Wave ", current_wave, " complete!")

	wave_complete_menu.show_menu()
