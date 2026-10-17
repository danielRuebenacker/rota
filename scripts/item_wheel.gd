extends Polygon2D

@export var radius: float = 50.0
@export var pulse_duration: float = 0.1

var vertices: int = 0
var item_index: int = 0

var item_list: Array[PackedScene] = []

func _ready() -> void:
	draw_items()

func add_item(item_scene: PackedScene) -> void:
	if item_scene == null:
		return
	item_list.append(item_scene)
	item_index = item_list.size() - 1
	vertices = item_list.size()
	generate_circle()
	draw_items()

func has_items() -> bool:
	return not item_list.is_empty()

func generate_circle() -> void:
	if vertices < 2:
		polygon = PackedVector2Array()
		return

	var points := PackedVector2Array()

	for i in range(vertices):
		var angle := TAU * i / vertices
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	polygon = points


@export var item_scale: float = 0.3
@export var item_inset: float = 0.75

func draw_items() -> void:
	for child in get_children():
		child.queue_free()

	if item_list.size() < 3:
		polygon = PackedVector2Array()

	for i in range(item_list.size()):
		var item_scene := item_list[i].instantiate()
		var original_sprite := item_scene.get_node("Sprite2D") as Sprite2D

		var sprite := Sprite2D.new()
		sprite.texture = original_sprite.texture
		sprite.scale = Vector2.ONE * item_scale
		sprite.position = Vector2.ZERO if item_list.size() == 1 else polygon[i] * item_inset

		add_child(sprite)
		item_scene.free()

func pulse_rotation() -> void:
	if item_list.size() < 2:
		return

	item_index += 1
	if item_index >= item_list.size():
		item_index = 0

	var tween := create_tween()

	tween.tween_property(
		self,
		"rotation_degrees",
		rotation_degrees + 360.0 / item_list.size(),
		pulse_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	
func get_current_item() -> PackedScene:
	if item_list.is_empty():
		return null

	return item_list[item_index]
