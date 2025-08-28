extends Node2D

@export var turns_to_explode: int = 3
@export var damage_radius: int = 2
@export var start_count: bool = false
@export var deal_damage: bool = true

@onready var tile_map_layer: TileMapLayer = $"../../MineTileMapLayer"
@onready var tile_map_layer2: TileMapLayer = $"../../FogTileMapLayer"
@onready var objects_manager: Node2D = $"../../../ObjectsManager"

@onready var label: Label = $"Label"

var grid_pos: Vector2i


var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
}

func _ready() -> void:
	# Find our grid position in tilemap space
	grid_pos = tile_map_layer.local_to_map(global_position)


func use_object() -> void:
	start_count = true
	label.add_theme_font_size_override("Size",16)
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
	tile_map_layer.erase_cell(grid_pos)
	tile_map_layer.set_cells_terrain_connect([grid_pos], 0, -1)
	var surround = tile_map_layer.get_surrounding_cells(grid_pos)
	for x in surround:
		tile_map_layer.erase_cell(x)
		tile_map_layer.set_cells_terrain_connect([x], 0, -1)
		'if objects_manager.objects.has(x):
			objects_manager.objects[x].queue_free()' # here change to start floating animation


	var surround2 = tile_map_layer2.get_surrounding_cells(grid_pos)
	for x in surround2:
		var surround3 = tile_map_layer2.get_surrounding_cells(x)
		for y in surround3:
			tile_map_layer2.erase_cell(y)
			tile_map_layer2.set_cells_terrain_connect([y], 0, -1)

	if deal_damage:
		_damage_player_if_near()

	queue_free()


func _damage_player_if_near() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var player_cell = tile_map_layer.local_to_map(player.global_position)
	if player_cell.distance_to(grid_pos) <= damage_radius:
		ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -5)
