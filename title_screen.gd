extends Control

@export var animation: AnimationPlayer
@export var video: VideoStreamPlayer
@export var layer: CanvasLayer

var allow = false

func _ready() -> void:
	video.finished.connect(_on_video_finished)

func _unhandled_input(event: InputEvent) -> void:
	if !allow:
		return
	if event is InputEventKey and event.pressed:
		_start_main()

func _gui_input(event: InputEvent) -> void:
	if !allow:
		return
	if event.is_pressed():
		_start_main()

func _on_video_finished() -> void:
	layer.queue_free()
	allow = true

func _start_main() -> void:
	animation.play("zoom")
	await animation.animation_finished
	get_tree().change_scene_to_file("res://main/main.tscn")
