extends Node2D

@export var block_density: int = 3
@export var reveal_radius: int = 3

@onready var tile_map_layer: TileMapLayer = $"../../MineTileMapLayer"
@onready var tile_map_layer2: TileMapLayer = $"../../FogTileMapLayer"
@onready var objects_manager: Node2D = $"../../../ObjectsManager"

var grid_pos: Vector2i


func _ready() -> void:
	grid_pos = tile_map_layer.local_to_map(global_position)


func use_object() -> void:
	block_density -= 1
	if block_density <= 0:
		_reveal_area()
		queue_free()


func _reveal_area() -> void:
	for x in range(-reveal_radius, reveal_radius + 1):
		for y in range(-reveal_radius, reveal_radius + 1):
			var offset = Vector2i(x, y)
			var target = grid_pos + offset
			if objects_manager.objects.has(target):
				
				if offset.length() <= reveal_radius:
					# Fog entfernen
					if tile_map_layer2.get_cell_source_id(target) != -1:
						tile_map_layer2.erase_cell(target)
						tile_map_layer2.set_cells_terrain_connect([target], 0, -1)
