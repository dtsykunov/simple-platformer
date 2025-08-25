extends Control

@export var score_label: Label

func _ready() -> void:
    score_label.text = str(ResourceManager.resources[ResourceManager.ResourceType.GOAL] - 1)
