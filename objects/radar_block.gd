extends Node2D

signal fully_used

@export var block_density: int = 2
@export var reveal_radius: int = 2
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func use_object() -> void:
	block_density -= 1
	if block_density <= 0:
		fully_used.emit()
		hide()
		Global.grid_spawner.reveal_cell_at_position(position, reveal_radius)
		sound.play()
		sound.finished.connect(queue_free)
