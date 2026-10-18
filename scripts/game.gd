extends Node2D

signal change_item_pulse

@export var pulse_interval: float = 2.0
@export_range(0.0, 1.0) var enemy_drop_chance: float = 0.35
@export var helicopter_drop_scene: PackedScene
@export var machine_gun_drop_scene: PackedScene
@export var shotgun_drop_scene: PackedScene
@export var potion_drop_scene: PackedScene

@onready var wheel = $CanvasLayer/ItemWheel/Polygon2D
@onready var player = $Player
@onready var timer: Timer = $ItemTimer
var random_source := RandomNumberGenerator.new()


func _ready() -> void:
	random_source.randomize()
	change_item_pulse.connect(wheel.pulse_rotation)
	change_item_pulse.connect(update_player_weapon)

	timer.wait_time = pulse_interval
	timer.timeout.connect(func(): change_item_pulse.emit())
	timer.start()

	wheel.add_item(preload("res://scenes/item_gun.tscn"))
	wheel.add_item(preload("res://scenes/item_healing_potion.tscn"))
	update_player_weapon()


func spawn_enemy_drop(drop_position: Vector2) -> void:
	if random_source.randf() > enemy_drop_chance:
		return

	var drop_scene := _choose_enemy_drop()
	if drop_scene == null:
		return

	var drop := drop_scene.instantiate() as Node2D
	if drop == null:
		push_warning("Enemy drop scene must instantiate a Node2D")
		return

	drop.global_position = drop_position
	add_child(drop)


func _choose_enemy_drop() -> PackedScene:
	var available_drops: Array[PackedScene] = []
	var drop_weights: Array[float] = []

	if helicopter_drop_scene != null:
		available_drops.append(helicopter_drop_scene)
		drop_weights.append(1.0)
	if machine_gun_drop_scene != null:
		available_drops.append(machine_gun_drop_scene)
		drop_weights.append(3.0)
	if shotgun_drop_scene != null:
		available_drops.append(shotgun_drop_scene)
		drop_weights.append(6.0)
	if potion_drop_scene != null:
		available_drops.append(potion_drop_scene)
		drop_weights.append(10.0)

	if available_drops.is_empty():
		return null

	var total_weight := 0.0
	for weight in drop_weights:
		total_weight += weight

	var roll := random_source.randf_range(0.0, total_weight)
	for i in range(available_drops.size()):
		roll -= drop_weights[i]
		if roll <= 0.0:
			return available_drops[i]

	return available_drops.back()

func collect_weapon(weapon_scene: PackedScene) -> void:
	wheel.add_item(weapon_scene)
	update_player_weapon()

func update_player_weapon() -> void:
	var item_scene = wheel.get_current_item()

	if item_scene != null and player != null and wheel.has_items():
		player.equip_weapon(item_scene)
		
