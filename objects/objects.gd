class_name MiningObject
extends Node2D

@export var selected_resource: ResourceManager.ResourceType
@export var resource_value: int = 1
@export var block_density: int = 1 # how many hits to break the block

func use_object():
	block_density -= 1
	if block_density <= 0:
		queue_free()
	ResourceManager.add_resource(selected_resource, resource_value)
