extends Node2D

@export var cloud_scene: PackedScene 
@export var throw_distance: float = 250.0
@export var throw_duration: float = 0.4
@export var cooldown: float = 5.0

@onready var sprite: Sprite2D = $Sprite2D

var can_use := true


func use() -> void:
	if not can_use:
		return

	can_use = false
	throw_potion()

	await get_tree().create_timer(cooldown).timeout
	can_use = true


func throw_potion() -> void:
	var player := get_parent().get_parent() as Player

	var direction := player.get_player_direction()
	var target_position := global_position + direction * throw_distance

	# create a separate sprite for the thrown potion
	var potion := Sprite2D.new()
	potion.texture = sprite.texture

	get_tree().current_scene.add_child(potion)
	potion.global_position = global_position
	potion.global_rotation = 0.0

	var tween := create_tween()

	tween.tween_property(
		potion,
		"global_position",
		target_position,
		throw_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	# create harming cloud on landing
	var cloud := cloud_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(cloud)
	cloud.global_position = target_position

	potion.queue_free()
