class_name Main
extends Node

enum GameState {
	START_MENU,
	PLAYING,
	UPGRADING,
	END_SCREEN,
}
var game_state: GameState = GameState.START_MENU

@export_file var finish_game_scene: String
@export_file var game_gui_scene: String
@export_file var upgrades_screen_scene: String

@export_file var world_scene: String

@onready var gui: CanvasLayer = $GUI
@onready var world: Node2D = $World

@export var animation: AnimationPlayer


func _ready() -> void:
	Global.game_controller = self
	Global.player_reached_surface.connect(_on_player_reached_surface)
	ResourceManager.oxygen_depleted.connect(finish_game)

func _change_gui(scene_path: String) -> void:
	var new_gui = load(scene_path).instantiate()
	gui.get_child(0).queue_free()
	gui.add_child(new_gui)

func _change_world(scene_path: String) -> void:
	var new_world = load(scene_path).instantiate()
	world.get_child(0).queue_free()
	world.add_child(new_world)

func start_game() -> void:
	if game_state not in [GameState.START_MENU, GameState.UPGRADING]:
		return
	animation.play("main_transition")
	await animation.animation_finished
	game_state = GameState.PLAYING
	ResourceManager.renew()
	_change_gui(game_gui_scene)
	_change_world(world_scene)
	world.visible = true
	animation.play_backwards("main_transition")

func finish_game() -> void:
	if game_state != GameState.PLAYING:
		return
	game_state = GameState.END_SCREEN
	_change_gui(finish_game_scene)
	world.visible = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		animation.stop()
		ResourceManager.reset()
		get_tree().reload_current_scene()

func _on_player_reached_surface() -> void: ## change with grid position condition
	if game_state != GameState.PLAYING:
		return
	if ResourceManager.is_goal_reached():
		game_state = GameState.UPGRADING
		ResourceManager.add_resource(ResourceManager.ResourceType.MONEY, -ResourceManager.resources[ResourceManager.ResourceType.GOAL])
		ResourceManager.add_resource(ResourceManager.ResourceType.GOAL, 1)
		_change_gui(upgrades_screen_scene)
