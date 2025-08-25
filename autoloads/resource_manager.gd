extends Node

const MAX_OXYGEN: int = 20

signal resources_changed
signal oxygen_depleted

enum ResourceType {
	MONEY,
	OXYGEN,
	GOAL,
}

@export var default_resources: Dictionary[ResourceType, int] = {
	ResourceType.MONEY: 0, # you can leave those blank this is just what you start with
	ResourceType.OXYGEN: MAX_OXYGEN,
	ResourceType.GOAL: 1,
}

@export var default_multipliers: Dictionary[ResourceType, int] = {
	ResourceType.MONEY: 1,
	ResourceType.OXYGEN: 1,
}

var resources := {}
var multipliers := {}

func _ready() -> void:
	reset()

func add_resource(resource_name: ResourceType, value: int, ignore_multipliers: bool = false) -> void:
	if not ignore_multipliers:
		value = _apply_multipliers(resource_name, value)

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

func try_complete_goal() -> void:
	var goal = resources[ResourceType.GOAL]
	if resources[ResourceType.MONEY] >= goal:
		add_resource(ResourceType.GOAL, +1)
		add_resource(ResourceType.MONEY, -goal, true) # ignore multipliers when subtracting money
		set_resource_value(ResourceType.OXYGEN, _apply_multipliers(ResourceType.OXYGEN, MAX_OXYGEN))
		Global.level_objective_reached.emit()

func _apply_multipliers(resource_name: ResourceType, value: int) -> int:
	if not multipliers.has(resource_name):
		return value
	return value * multipliers[resource_name]

func reset() -> void:
	_reset_resources()
	_reset_multipliers()

func _reset_resources() -> void:
	resources = default_resources.duplicate()

func _reset_multipliers() -> void:
	multipliers = default_multipliers.duplicate()
