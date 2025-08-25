class_name Main
extends Node

@export_file var finish_game_scene: String
@export_file var game_gui_scene: String

@export_file var world_scene: String

@onready var gui: Control = $GUI
@onready var world: Node2D = $World


func _ready() -> void:
	Global.game_controller = self

	ResourceManager.oxygen_depleted.connect(finish_game)

func change_gui(scene_path: String) -> void:
	var new_gui = load(scene_path).instantiate()
	gui.get_child(0).queue_free()
	gui.add_child(new_gui)

func change_world(scene_path: String) -> void:
	var new_world = load(scene_path).instantiate()
	world.get_child(0).queue_free()
	world.add_child(new_world)

func load_next_world() -> void:
	change_world(world_scene)

func start_game() -> void:
	print("Starting game...")
	change_gui(game_gui_scene)
	load_next_world()
	world.visible = true

func finish_game() -> void:
	change_gui(finish_game_scene)
	world.visible = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		ResourceManager.reset()
		get_tree().reload_current_scene()
