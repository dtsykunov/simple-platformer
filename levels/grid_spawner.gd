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
			var selected_scene = select_mining_object_scene(y)
			if selected_scene != null:
				var cell_pos = Vector2i(x, y) + offset
				var instance = selected_scene.instantiate()
				instance.position = cell_pos * Global.tile_size
				instance.tree_exiting.connect(erase_cell.bind(cell_pos))
				mine_tile_map_layer.add_child(instance)
				objects[cell_pos] = instance

func select_mining_object_scene(height: int) -> PackedScene:
	# TODO: this code is not the best because on layers where there're multiple ores, you have more of them
	for entry in scenes:
		if height < entry.gen_height_min:
			continue
		if entry.gen_height_max != ObjectEntry.NO_MAX_LIMIT and height > entry.gen_height_max:
			continue
		if randf() <= entry.probability:
			return entry.scene
	return null


func erase_cell(cell_pos: Vector2i) -> void:
	objects.erase(cell_pos)
	mine_tile_map_layer.erase_cell(cell_pos)
	mine_tile_map_layer.set_cells_terrain_connect([cell_pos], 0, -1)
	fog_tile_map_layer.erase_cell(cell_pos)
	fog_tile_map_layer.set_cells_terrain_connect(fog_tile_map_layer.get_surrounding_cells(cell_pos), 0, -1)

func _get_cells_at_position(pos: Vector2, radius: int = 0) -> Array: # Array[Vector2i]
	var start_cell: Vector2i = mine_tile_map_layer.local_to_map(pos)
	var visited: Dictionary[Vector2i, bool] = {start_cell: true}
	var frontier := [start_cell]
	for i in range(radius):
		var new_frontier := []
		for cell in frontier:
			for neighbor in mine_tile_map_layer.get_surrounding_cells(cell):
				if neighbor not in visited:
					visited[neighbor] = true
					new_frontier.append(neighbor)
		frontier = new_frontier
	return visited.keys()

func reveal_cell_at_position(pos: Vector2, radius: int = 0) -> void:
	var cells = _get_cells_at_position(pos, radius)
	fog_tile_map_layer.set_cells_terrain_connect(cells, 0, -1)

func use_cell_at_position(pos: Vector2, radius: int = 0) -> void:
	var cells = _get_cells_at_position(pos, radius)
	for cell in cells:
		if cell in objects:
			objects[cell].use_object()
		else:
			erase_cell(cell)
		_emit_particle(cell)
	_play_sound()


func _emit_particle(pos: Vector2i) -> void:
	var particle = block_particle.instantiate()
	particle.position = mine_tile_map_layer.map_to_local(pos)
	particle.emitting = true
	add_child(particle)
	particle.finished.connect(particle.queue_free)


func _play_sound() -> void:
	sound_player.play()
