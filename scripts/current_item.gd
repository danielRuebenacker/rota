extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


@onready var current_item: Item = $Item

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		current_item.use()
