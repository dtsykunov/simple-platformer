extends Control

@export var money_label: Label
@export var goal_label: Label
@export var oxygen_label: Label

@onready var labels = {
	ResourceManager.ResourceType.MONEY: money_label,
	ResourceManager.ResourceType.OXYGEN: oxygen_label,
	ResourceManager.ResourceType.GOAL: goal_label,
}

func _ready() -> void:
	_on_resources_changed()
	ResourceManager.resources_changed.connect(_on_resources_changed)

func _on_resources_changed() -> void:
	for resource_name in ResourceManager.resources.keys():
		if resource_name in labels:
			labels[resource_name].text = str(ResourceManager.resources[resource_name])
