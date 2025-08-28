class_name MiningObject
extends Node2D

@export var selected_resource: ResourceManager.ResourceType
@export var resource_value: int = 1
@export var block_density: int = 1 # how many hits to break the block

@export var random_images: Array[Texture2D] = []
func _ready() -> void:
	if random_images.is_empty():
		return
	
	var tex_rect: TextureRect = $TextureRect
	var random_texture: Texture2D = random_images.pick_random()
	tex_rect.texture = random_texture

func use_object():
	block_density -= 1
	if block_density <= 0:
		ResourceManager.add_resource(selected_resource, resource_value)
		queue_free()
