extends Node2D

var resource_manager: Node

@export var selected_resource: String
@export var resource_value: int = 1

func _ready():
	resource_manager = get_node("/root/Main/World/Basic/ResourceManager")

func use_object():
	if resource_manager and selected_resource != "":
		resource_manager.add_resource(selected_resource, resource_value)
