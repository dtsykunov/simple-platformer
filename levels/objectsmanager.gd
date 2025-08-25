class_name GridSpawner
extends Node2D

@export var scenes: Array[ObjectEntry] = []

@export var grid_size_x: int = 10
@export var grid_size_y: int = 10
@export var offset: Vector2i = Vector2i.ZERO

var objects: Dictionary[Vector2i, Node] = {}

func _ready():
	spawn_grid()
	Global.grid_spawner = self

func spawn_grid():
	for x in range(grid_size_x):
		for y in range(grid_size_y):
			var selected_scene = get_scene_by_probability()
			if selected_scene != null:
				var instance = selected_scene.instantiate()
				instance.position = (Vector2i(x, y) * Global.tile_size) + (offset * Global.tile_size)
				add_child(instance)
				objects[Vector2i(x, y) + offset] = instance

# Picks a scene based on its probability
func get_scene_by_probability() -> PackedScene:
	var r = randf()
	var cumulative = 0.0
	for entry in scenes:
		cumulative += entry.probability
		if r <= cumulative:
			return entry.scene
	return null
