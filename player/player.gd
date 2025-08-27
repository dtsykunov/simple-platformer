extends CharacterBody2D

@onready var ray = $RayCast2D

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
	ray.target_position = inputs[dir] * Global.tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * Global.tile_size
		if last_player_pos.y != position.y and position.y < 3 * Global.tile_size: # 3 for space tiles maybe add a check var
			Global.player_reached_surface.emit()
		ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)
		last_player_pos = position
		return

	Global.grid_spawner.use_cell_at_position(ray.target_position + position)

	ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)
