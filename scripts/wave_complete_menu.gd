extends Control

@export var wave_manager: WaveManager
@export var item_wheel: Node

@onready var wave_label: Label = $PanelContainer/VBoxContainer/WaveLabel
@onready var unlocked_label: Label = $PanelContainer/VBoxContainer/UnlockedItemLabel
@onready var wheel_slots: HBoxContainer = $PanelContainer/VBoxContainer/WheelSlots
@onready var available_items: GridContainer = $PanelContainer/VBoxContainer/AvailableItems
@onready var continue_button: Button = $PanelContainer/VBoxContainer/ContinueButton

var equipped_items: Array[PackedScene] = []
var available_scenes: Array[PackedScene] = []
var selected_slot := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	continue_button.pressed.connect(_on_continue_pressed)


func open_editor(
	wave: int,
	new_item: PackedScene,
	unlocked: Array[PackedScene]
) -> void:
	wave_label.text = "WAVE %d COMPLETE!" % wave

	if new_item != null:
		unlocked_label.text = "New item unlocked: " + get_item_name(new_item)
	else:
		unlocked_label.text = "All items unlocked!"

	equipped_items.clear()

	for item in item_wheel.get("item_list"):
		equipped_items.append(item as PackedScene)

	available_scenes = unlocked.duplicate()
	selected_slot = 0

	refresh_slots()
	refresh_available_items()

	visible = true
	get_tree().paused = true


func refresh_slots() -> void:
	for child in wheel_slots.get_children():
		child.queue_free()

	for i in range(equipped_items.size()):
		var button := Button.new()
		var item := equipped_items[i]

		button.text = get_item_name(item)
		button.custom_minimum_size = Vector2(120, 60)

		if i == selected_slot:
			button.text = "> " + button.text + " <"

		button.pressed.connect(select_slot.bind(i))
		wheel_slots.add_child(button)


func refresh_available_items() -> void:
	for child in available_items.get_children():
		child.queue_free()

	for item in available_scenes:
		var button := Button.new()

		button.text = get_item_name(item)
		button.custom_minimum_size = Vector2(120, 60)

		button.pressed.connect(equip_item.bind(item))
		available_items.add_child(button)


func select_slot(index: int) -> void:
	selected_slot = index
	refresh_slots()


func equip_item(item: PackedScene) -> void:
	if selected_slot < 0 or selected_slot >= equipped_items.size():
		return

	equipped_items[selected_slot] = item

	refresh_slots()


func get_item_name(item: PackedScene) -> String:
	if item == null:
		return "Empty"

	return item.resource_path.get_file().get_basename().capitalize()


func _on_continue_pressed() -> void:
	# Save the edited wheel
	item_wheel.set("item_list", equipped_items.duplicate())

	# Tell the item wheel to rebuild its icons
	if item_wheel.has_method("refresh_items"):
		item_wheel.call("refresh_items")

	visible = false
	get_tree().paused = false

	wave_manager.start_next_wave()
