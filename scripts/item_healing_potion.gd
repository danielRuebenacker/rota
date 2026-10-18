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
	if cloud_scene == null:
		return

	var player := get_parent().get_parent() as Player

	var direction := player.get_player_direction()
	var target_position := global_position + direction * throw_distance

	# create a separate sprite for the thrown potion
	var potion := Sprite2D.new()
	potion.texture = sprite.texture

	var scene := get_tree().current_scene
	scene.add_child(potion)
	potion.global_position = global_position
	potion.global_rotation = 0.0

	# Store the cloud scene before the weapon is removed
	var cloud_resource := cloud_scene

	var tween := potion.create_tween()

	tween.tween_property(
		potion,
		"global_position",
		target_position,
		throw_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# create the cloud when the tween finishes
	tween.tween_callback(func():
		var cloud := cloud_resource.instantiate() as Area2D
		scene.add_child(cloud)
		cloud.global_position = target_position

		potion.queue_free()
	)
