class_name MiningObject
extends Node2D

@export var selected_resource: ResourceManager.ResourceType
@export var resource_value: int = 1

func use_object():
	ResourceManager.add_resource(selected_resource, resource_value)
