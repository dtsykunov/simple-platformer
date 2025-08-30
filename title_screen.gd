extends Control

@export var animation: AnimationPlayer
@export var video: VideoStreamPlayer
@export var layer: CanvasLayer

@export var particle_scene : PackedScene

var allow = false
var started = false

func _ready() -> void:
	_emit_particle()
	video.finished.connect(_on_video_finished)
	video.play()

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
	if started:
		return
	started = true
	animation.play("zoom")
	await animation.animation_finished
	get_tree().change_scene_to_file("res://main/main.tscn")

func _emit_particle() -> void:
	var particle = particle_scene.instantiate()
	particle.emitting = true
	add_child(particle)
	particle.finished.connect(particle.queue_free)
	
