extends Polygon2D

@export var radius: float = 50.0
@export var pulse_duration: float = 0.1

var vertices: int = 8
var item_index: int = 0

var item_list: Array[PackedScene] = [
	preload("res://scenes/item_gun.tscn"),
	preload("res://scenes/item_gun.tscn"),
	preload("res://scenes/item_gun.tscn"),
	preload("res://scenes/item_gun.tscn"),
	preload("res://scenes/item_gun.tscn"),
	preload("res://scenes/item_gun.tscn"),
	preload("res://scenes/item_gun.tscn"),
	preload("res://scenes/item_gun.tscn")
]


func _ready() -> void:
	vertices = item_list.size()
	generate_circle()
	draw_items()


func generate_circle() -> void:
	if vertices < 3:
		return

	var points := PackedVector2Array()

	for i in range(vertices):
		var angle := TAU * i / vertices
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	polygon = points


@export var item_scale: float = 0.3
@export var item_inset: float = 0.75

func draw_items() -> void:
	for i in range(item_list.size()):
		var item_scene := item_list[i].instantiate()
		var original_sprite := item_scene.get_node("Sprite2D") as Sprite2D

		var sprite := Sprite2D.new()
		sprite.texture = original_sprite.texture
		sprite.scale = Vector2.ONE * item_scale
		sprite.position = polygon[i] * item_inset

		add_child(sprite)
		item_scene.free()


func pulse_rotation() -> void:
	if vertices < 3:
		return

	item_index += 1
	if item_index >= vertices:
		item_index = 0

	var tween := create_tween()

	tween.tween_property(
		self,
		"rotation_degrees",
		rotation_degrees + 360.0 / vertices,
		pulse_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	
func get_current_item() -> PackedScene:
	if item_list.is_empty():
		return null

	return item_list[item_index]
