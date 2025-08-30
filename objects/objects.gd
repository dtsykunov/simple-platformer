class_name MiningObject
extends Node2D

signal fully_used

enum State {
	IDLE,
	USED,
}
var state: State = State.IDLE

@export var selected_resource: ResourceManager.ResourceType
@export var resource_value: int = 1
@export var block_density: int = 1 # how many hits to break the block

@export var random_images: Array[Texture2D] = []

@onready var tex_rect: TextureRect = $TextureRect
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
var shader_mat: ShaderMaterial


func _ready() -> void:
	if !random_images.is_empty():
		var random_texture: Texture2D = random_images.pick_random()
		tex_rect.texture = random_texture

	if tex_rect.material is ShaderMaterial:
		shader_mat = (tex_rect.material as ShaderMaterial).duplicate() # each object has own material
	else:
		shader_mat = ShaderMaterial.new()
		shader_mat.shader = preload("res://objects/object_shader.gdshader")

	shader_mat.resource_local_to_scene = true
	tex_rect.material = shader_mat

func use_object() -> void:
	if state != State.IDLE:
		return

	block_density -= 1

	if block_density <= 0:
		print(block_density, "mined")
		state = State.USED
		hide()
		fully_used.emit()
		ResourceManager.add_resource(selected_resource, resource_value)

		if sound:
			sound.play()
			sound.finished.connect(queue_free)
		else:
			queue_free()

	if shader_mat:
		shader_mat.set_shader_parameter("flash", true)
		await get_tree().create_timer(0.1).timeout
		shader_mat.set_shader_parameter("flash", false)
