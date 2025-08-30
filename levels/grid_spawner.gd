class_name GridSpawner
extends Node2D

@export var scenes: Array[ObjectEntry] = []

@export var grid_size_x: int = 10
@export var grid_size_y: int = 10
@export var block_particle: PackedScene

@export var mine_offset_cells: Vector2i = Vector2i.ZERO

var objects: Dictionary[Vector2i, Node] = {}

@onready var mine_tile_map_layer: TileMapLayer = %MineTileMapLayer
@onready var fog_tile_map_layer: TileMapLayer = %FogTileMapLayer
@onready var sound_player: AudioStreamPlayer2D = $AudioStreamPlayer2DMining
@onready var sound_player_gold: AudioStreamPlayer2D = $AudioStreamPlayer2DGold
@onready var player: CharacterBody2D = $Player

@onready var _astar: AStarGrid2D = AStarGrid2D.new()

func _ready():
	_spawn_objects()
	_setup_astar()
	Global.grid_spawner = self

var _surface_points: Array[Vector2i] = []

func _setup_astar() -> void:
	_astar.region = Rect2i(0, 0, grid_size_x + 1, grid_size_y + 1)
	_astar.cell_size = Vector2i(Global.tile_size, Global.tile_size)
	_astar.offset = Vector2(Global.tile_size, Global.tile_size) * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()

	for x in range(mine_offset_cells.x, grid_size_x + mine_offset_cells.x):
		for y in range(mine_offset_cells.y, grid_size_y + mine_offset_cells.y):
			_astar.set_point_solid(Vector2i(x, y))

	for x in range(mine_offset_cells.x, grid_size_x + mine_offset_cells.x):
		_surface_points.append(Vector2i(x, mine_offset_cells.y - 1))

var _shortest_path: PackedVector2Array = PackedVector2Array()

func _draw() -> void:
	if _shortest_path.is_empty():
		return
	var last_point = _shortest_path[0]
	for index in range(1, len(_shortest_path)):
		var current_point = _shortest_path[index]
		draw_line(last_point, current_point, Color.WHITE, 2.0, true)
		draw_circle(current_point, 2.0 * 2.0, Color.WHITE)
		last_point = current_point

func _spawn_objects():
	# +1/-1 so that we don't spawn objects on the edges
	for x in range(mine_offset_cells.x + 1, grid_size_x + mine_offset_cells.x - 1):
		for y in range(mine_offset_cells.y + 1, grid_size_y + mine_offset_cells.y - 1):
			var cell_pos = Vector2i(x, y) + mine_offset_cells
			var selected_scene = select_mining_object_scene(y)
			if selected_scene != null:
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
	_astar.set_point_solid(cell_pos, false)

	queue_redraw()

func _get_cells_at_position(global_pos: Vector2, radius: int = 0) -> Array: # Array[Vector2i]
	var start_cell: Vector2i = mine_tile_map_layer.local_to_map(to_local(global_pos))
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

func use_cell_at_position(global_pos: Vector2, radius: int = 0) -> void:
	var cells = _get_cells_at_position(global_pos, radius)
	for cell in cells:
		if cell in objects:
			objects[cell].use_object()
			sound_player.play()
			sound_player_gold.play()
		else:
			erase_cell(cell)
			sound_player.play()
		_emit_particle(cell)


func _emit_particle(pos: Vector2i) -> void:
	var particle = block_particle.instantiate()
	particle.position = mine_tile_map_layer.map_to_local(pos)
	particle.emitting = true
	add_child(particle)
	particle.finished.connect(particle.queue_free)


func get_distance_in_cells(position1: Vector2, position2: Vector2) -> float:
	var grid_pos = mine_tile_map_layer.local_to_map(to_local(position1))
	var player_cell = mine_tile_map_layer.local_to_map(to_local(position2))
	return player_cell.distance_to(grid_pos)

func draw_path_to_surface(from_position_global: Vector2) -> void:
	_shortest_path = get_shortest_path_to_surface(from_position_global)
	queue_redraw()

func get_shortest_path_to_surface(from_position_global: Vector2) -> PackedVector2Array:
	var cell_pos: Vector2i = mine_tile_map_layer.local_to_map(to_local(from_position_global))

	var min_path = PackedVector2Array()
	for point in _surface_points:
		var path = _astar.get_point_path(point, cell_pos)
		if path.is_empty():
			continue
		if not min_path or len(min_path) > len(path):
			min_path = path
			continue
	return min_path
