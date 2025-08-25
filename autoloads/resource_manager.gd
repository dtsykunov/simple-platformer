extends Node

const MAX_OXYGEN: int = 20

signal resources_changed
signal oxygen_depleted

enum ResourceType {
	MONEY,
	OXYGEN,
	GOAL,
}

@export var default_resources := {
	ResourceType.MONEY: 0, # you can leave those blank this is just what you start with
	ResourceType.OXYGEN: MAX_OXYGEN,
	ResourceType.GOAL: 1,
}

var resources := {}
var resource_labels := {}

func _ready() -> void:
	reset_resources()

func add_resource(resource_name: ResourceType, value: int):
	if not resources.has(resource_name):
		set_resource_value(resource_name, value)
		return

	var new_value = resources[resource_name] + value
	if resource_name == ResourceType.OXYGEN:
		new_value = clamp(new_value, 0, MAX_OXYGEN)
		set_resource_value(resource_name, new_value)
		if new_value <= 0:
			oxygen_depleted.emit()
	else:
		set_resource_value(resource_name, new_value)

func set_resource_value(resource_name: ResourceType, value: int):
	resources[resource_name] = value
	resources_changed.emit()

func reset_resources() -> void:
	resources = default_resources.duplicate()
