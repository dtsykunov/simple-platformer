extends Control

@export var animation : AnimationPlayer

func _ready() -> void:
	animation.stop()
	animation.seek(0, true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_start_main()

func _gui_input(event: InputEvent) -> void:

	if event.is_pressed():
		_start_main()


func _start_main() -> void:
	animation.play("zoom")
	await animation.animation_finished
	get_tree().change_scene_to_file("res://main/main.tscn")
