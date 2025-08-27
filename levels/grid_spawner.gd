class_name GridSpawner
extends Node2D

@export var scenes: Array[ObjectEntry] = []

@export var grid_size_x: int = 10
@export var grid_size_y: int = 10
@export var offset: Vector2i = Vector2i.ZERO
@export var block_particle: PackedScene

var objects: Dictionary[Vector2i, Node] = {}

@onready var mine_tile_map_layer: TileMapLayer = $MineTileMapLayer
@onready var fog_tile_map_layer: TileMapLayer = $FogTileMapLayer
@onready var sound_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	spawn_grid()
	Global.grid_spawner = self

func spawn_grid():
	for x in range(grid_size_x):
		for y in range(grid_size_y):
			var selected_scene = get_scene_by_probability()
			if selected_scene != null:
				var cell_pos = Vector2i(x, y) + offset
				var instance = selected_scene.instantiate()
				instance.position = cell_pos * Global.tile_size
				instance.tree_exiting.connect(erase_cell.bind(cell_pos))
				mine_tile_map_layer.add_child(instance)
				objects[cell_pos] = instance


# Picks a scene based on its probability
func get_scene_by_probability() -> PackedScene:
	var r = randf()
	var cumulative = 0.0
	for entry in scenes:
		cumulative += entry.probability
		if r <= cumulative:
			return entry.scene
	return null

func erase_cell(cell_pos: Vector2i) -> void:
	objects.erase(cell_pos)
	mine_tile_map_layer.erase_cell(cell_pos)
	mine_tile_map_layer.set_cells_terrain_connect([cell_pos], 0, -1)
	fog_tile_map_layer.set_cells_terrain_connect(fog_tile_map_layer.get_surrounding_cells(cell_pos), 0, -1)

func use_cell_at_position(pos: Vector2) -> void:
	var cell_pos: Vector2i = mine_tile_map_layer.local_to_map(pos)
	if cell_pos in objects:
		objects[cell_pos].use_object()
	else:
		erase_cell(cell_pos)
	_emit_particle(cell_pos)
	_play_sound()

func _emit_particle(pos: Vector2i) -> void:
	var particle = block_particle.instantiate()
	particle.position = mine_tile_map_layer.map_to_local(pos)
	particle.emitting = true
	add_child(particle)
	particle.finished.connect(particle.queue_free)

func _play_sound() -> void:
	sound_player.play()
