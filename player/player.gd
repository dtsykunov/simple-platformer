extends CharacterBody2D

@export var tile_map_layer: TileMapLayer
@onready var ray = $RayCast2D

@export var block_particle: PackedScene

@onready var last_player_pos = position

var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
}

func _physics_process(_delta: float) -> void:
	if Global.game_controller.game_state != Main.GameState.PLAYING:
		return
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir):
			move(dir)

func move(dir):
	ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)

	ray.target_position = inputs[dir] * Global.tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * Global.tile_size
		if last_player_pos.y != position.y:
			ResourceManager.try_complete_goal(position)
		ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)
		last_player_pos = position
		return

	# TODO: move this logic to a separate script
	var cell: Vector2i = tile_map_layer.local_to_map(ray.target_position + position)

	var particle = block_particle.instantiate()
	particle.position = ray.target_position + position
	particle.emitting = true
	get_tree().current_scene.add_child(particle)

	if cell in Global.grid_spawner.objects:
		Global.grid_spawner.objects[cell].use_object()
		Global.grid_spawner.objects[cell].queue_free()
		Global.grid_spawner.objects.erase(cell)

	tile_map_layer.erase_cell(cell)
	tile_map_layer.set_cells_terrain_connect([cell], 0, -1)
	ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)
