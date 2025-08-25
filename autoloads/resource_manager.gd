extends Node

const MAX_OXYGEN: int = 20

signal resources_changed

signal oxygen_depleted

@export var resources := {
	"money": 0, # you can leave those blank this is just what you start with
	"oxygen": MAX_OXYGEN,
	"goal": 1,
}

@export var label_container: NodePath

var resource_labels := {}

func add_resource(resource_name: String, value: int):
	if not resources.has(resource_name):
		set_resource_value(resource_name, value)
		return

	var new_value = resources[resource_name] + value
	if resource_name == "oxygen":
		new_value = clamp(new_value, 0, MAX_OXYGEN)
		set_resource_value(resource_name, new_value)
		if new_value <= 0:
			oxygen_depleted.emit()
	else:
		set_resource_value(resource_name, new_value)

func set_resource_value(resource_name: String, value: int):
	resources[resource_name] = value
	resources_changed.emit()
