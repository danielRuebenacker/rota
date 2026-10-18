extends Label

@export var wave_manager: WaveManager


func _ready() -> void:
	wave_manager.wave_started.connect(update_wave)
	update_wave(wave_manager.current_wave)


func update_wave(wave: int) -> void:
	text = "Wave " + str(wave)
