extends CharacterBody2D

@export var tile_map_layer: TileMapLayer
@onready var ray = $RayCast2D

@onready var objects_manager = $"/root/Main/World/Basic/ObjectsManager"

@onready var resource_manager = get_node("/root/Main/World/Basic/ResourceManager")

var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
}

func _unhandled_input(event):
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	resource_manager.add_resource("oxygen", -1)
	
	ray.target_position = inputs[dir] * Global.tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * Global.tile_size
		return


	# TODO: move this logic to a separate script
	var cell: Vector2i = tile_map_layer.local_to_map(ray.target_position + position)
	
	
	# new
	if cell in objects_manager.objects:
		objects_manager.objects[cell].use_object()
		objects_manager.objects[cell].free()
		objects_manager.objects.erase(cell)

		
	tile_map_layer.erase_cell(cell)
	tile_map_layer.set_cells_terrain_connect([cell], 0, -1)
	# if not cells_health.has(cell):
	# 	var tile_data = tile_map_layer.get_cell_tile_data(cell)
	# 	var health = tile_data.get_custom_data("health")
	# 	cells_health[cell] = health

	# if cells_health.has(cell):
	# 	cells_health[cell] -= 1
	# 	if cells_health[cell] <= 0:
	# 		cells_health.erase(cell)
	# 		tile_map_layer.erase_cell(cell)
	# 		tile_map_layer.set_cells_terrain_connect([cell], 0, -1)
