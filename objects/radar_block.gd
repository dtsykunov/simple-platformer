extends Node2D

@export var block_density: int = 2
@export var reveal_radius: int = 2

@onready var tile_map_layer: TileMapLayer = $"../../MineTileMapLayer"
@onready var tile_map_layer2: TileMapLayer = $"../../FogTileMapLayer"
@onready var objects_manager: Node2D = $"../../../ObjectsManager"

var grid_pos: Vector2i


func _ready() -> void:
	grid_pos = tile_map_layer.local_to_map(global_position)


func use_object() -> void:
	block_density -= 1
	if block_density <= 0:
		Global.grid_spawner.reveal_cell_at_position(global_position, reveal_radius)
		queue_free()
