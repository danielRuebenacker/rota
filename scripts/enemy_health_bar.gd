extends ProgressBar

@export var offset := Vector2(-28, -42)

var enemy: Enemy
@onready var level_label: Label = $LevelLabel

func _ready() -> void:
	enemy = get_parent() as Enemy
	if enemy == null:
		push_warning("EnemyHealthBar must be a child of an Enemy")
		return

	top_level = true
	max_value = enemy.max_health
	value = enemy.health
	level_label.text = "Lv.%d" % enemy.level
	enemy.health_changed.connect(_on_health_changed)
	_on_health_changed()

func _process(_delta: float) -> void:
	if is_instance_valid(enemy):
		global_position = enemy.global_position + offset
		rotation = 0.0

func _on_health_changed() -> void:
	if is_instance_valid(enemy):
		value = enemy.health
		level_label.text = "Lv.%d" % enemy.level
