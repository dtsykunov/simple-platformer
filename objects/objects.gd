class_name MiningObject
extends Node2D

@export var selected_resource: ResourceManager.ResourceType
@export var resource_value: int = 1
@export var block_density: int = 1 # how many hits to break the block

@export var random_images: Array[Texture2D] = []

@onready var tex_rect: TextureRect = $TextureRect
var shader_mat: ShaderMaterial

func _ready() -> void:
	if !random_images.is_empty():
		var random_texture: Texture2D = random_images.pick_random()
		tex_rect.texture = random_texture
		
	if tex_rect.material is ShaderMaterial:
		shader_mat = (tex_rect.material as ShaderMaterial).duplicate() # each object has own material
	else:
		shader_mat = ShaderMaterial.new()
		shader_mat.shader = preload("res://objects/object_flash.gdshader")

	shader_mat.resource_local_to_scene = true
	tex_rect.material = shader_mat

func use_object():
	block_density -= 1
	if shader_mat:
		shader_mat.set_shader_parameter("flash", true)
		await get_tree().create_timer(0.1).timeout
		shader_mat.set_shader_parameter("flash", false)
	if block_density <= 0:
		ResourceManager.add_resource(selected_resource, resource_value)
		queue_free()
