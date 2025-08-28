extends Node2D

@export var turns_to_explode: int = 3
@export var damage_radius: int = 2
@export var start_count: bool = false
@export var deal_damage: bool = true

@onready var tile_map_layer: TileMapLayer = $"../../MineTileMapLayer"
@onready var tile_map_layer2: TileMapLayer = $"../../FogTileMapLayer"

@onready var label: Label = $"Label"

var grid_pos: Vector2i


var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
}


func use_object() -> void:
	start_count = true
	label.add_theme_font_size_override("Size", 16)
	label.text = str(turns_to_explode)

func _physics_process(_delta: float) -> void:
	if Global.game_controller.game_state != Main.GameState.PLAYING:
		return
	if !start_count:
		return
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir):
			process_turn()


func process_turn() -> void:
	turns_to_explode -= 1
	label.text = str(turns_to_explode)
	if turns_to_explode <= 0:
		_trigger_explosion()


func _trigger_explosion() -> void:
	Global.grid_spawner.use_cell_at_position(global_position, damage_radius)

	if deal_damage:
		_damage_player_if_near()

	queue_free()


func _damage_player_if_near() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	if Global.grid_spawner.get_distance_in_cells(global_position, player.global_position) <= damage_radius:
		ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -5)
