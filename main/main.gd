class_name Main
extends Node

@export_file var finish_game_scene: String

@export_file var worlds: Array[String]
var current_world_index: int = -1

@onready var gui: Control = $GUI
@onready var world: Node2D = $World


func _ready() -> void:
	Global.game_controller = self

func change_gui(scene_path: String) -> void:
	var new_gui = load(scene_path).instantiate()
	gui.get_child(0).queue_free()
	gui.add_child(new_gui)

func change_world(scene_path: String) -> void:
	var new_world = load(scene_path).instantiate()
	world.get_child(0).queue_free()
	world.add_child(new_world)

func load_next_world() -> void:
	current_world_index += 1
	if current_world_index < worlds.size():
		world.get_child(0).queue_free()
		var next_world = worlds[current_world_index]
		change_world(next_world)
	else:
		finish_game()

func start_game() -> void:
	print("Starting game...")
	gui.visible = false
	load_next_world()
	world.visible = true

func finish_game() -> void:
	change_gui(finish_game_scene)
	gui.visible = true
	world.visible = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
