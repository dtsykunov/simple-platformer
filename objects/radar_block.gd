extends Node2D

@export var block_density: int = 2
@export var reveal_radius: int = 2

func use_object() -> void:
	block_density -= 1
	if block_density <= 0:
		Global.grid_spawner.reveal_cell_at_position(global_position, reveal_radius)
		queue_free()
