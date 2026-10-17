extends Polygon2D

@export var radius: float = 50.0
@export var pulse_duration: float = 0.1

var vertices: int = 0
var item_index: int = 0
const DISPLAY_VERTICES := 32

var item_list: Array[PackedScene] = []

func _ready() -> void:
	generate_circle()
	draw_items()
	visible = false

func add_item(item_scene: PackedScene) -> void:
	if item_scene == null:
		return
	item_list.append(item_scene)
	item_index = item_list.size() - 1
	vertices = item_list.size()
	rotation = -PI / 4.0 - TAU * item_index / item_list.size()
	generate_circle()
	draw_items()
	visible = true
	queue_redraw()

func has_items() -> bool:
	return not item_list.is_empty()

func generate_circle() -> void:
	var points := PackedVector2Array()

	for i in range(DISPLAY_VERTICES):
		var angle := TAU * i / DISPLAY_VERTICES
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	polygon = points


@export var item_scale: float = 0.2
@export var item_inset: float = 0.75

func draw_items() -> void:
	for child in get_children():
		child.queue_free()

	for i in range(item_list.size()):
		var item_scene := item_list[i].instantiate()
		var original_sprite := item_scene.get_node("Sprite2D") as Sprite2D

		var sprite := Sprite2D.new()
		sprite.texture = original_sprite.texture
		sprite.scale = Vector2.ONE * item_scale
		if item_list.size() == 1:
			sprite.position = Vector2.ZERO
		else:
			var angle := TAU * i / item_list.size()
			sprite.position = Vector2(cos(angle), sin(angle)) * radius * item_inset

		add_child(sprite)
		item_scene.free()

func _draw() -> void:
	if item_list.is_empty():
		return

	var fixed_selection_position := Vector2(radius * item_inset, -radius * item_inset)
	var selected_position := fixed_selection_position.rotated(-rotation)

	draw_arc(selected_position, 18.0, 0.0, TAU, 24, Color("#ffe066"), 3.0)
	draw_line(selected_position + Vector2(-24, 0), selected_position + Vector2(-18, 0), Color("#ffe066"), 3.0)
	draw_line(selected_position + Vector2(18, 0), selected_position + Vector2(24, 0), Color("#ffe066"), 3.0)
	draw_line(selected_position + Vector2(0, -24), selected_position + Vector2(0, -18), Color("#ffe066"), 3.0)
	draw_line(selected_position + Vector2(0, 18), selected_position + Vector2(0, 24), Color("#ffe066"), 3.0)

func pulse_rotation() -> void:
	if item_list.size() < 2:
		return

	item_index += 1
	if item_index >= item_list.size():
		item_index = 0
	queue_redraw()

	var tween := create_tween()

	tween.tween_property(
		self,
		"rotation_degrees",
		rotation_degrees - 360.0 / item_list.size(),
		pulse_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	
func get_current_item() -> PackedScene:
	if item_list.is_empty():
		return null

	return item_list[item_index]
