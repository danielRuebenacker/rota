class_name Loot
extends StaticBody2D

@export var pickup_scene: PackedScene
var is_being_picked_up := false

func get_pickup_scene() -> PackedScene:
	return pickup_scene

func animate_pickup(player: Node2D) -> void:
	if is_being_picked_up:
		return
	is_being_picked_up = true
	collision_layer = 0
	collision_mask = 0
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(self, "global_position", player.global_position, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
