extends Area2D

func _ready() -> void:
    body_entered.connect(_on_win_area_body_entered)

func _on_win_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        var goal = ResourceManager.resources[ResourceManager.ResourceType.GOAL]
        if ResourceManager.resources[ResourceManager.ResourceType.MONEY] >= goal:
            ResourceManager.add_resource(ResourceManager.ResourceType.GOAL, +1)
            ResourceManager.add_resource(ResourceManager.ResourceType.MONEY, -goal)
            ResourceManager.set_resource_value(ResourceManager.ResourceType.OXYGEN, ResourceManager.MAX_OXYGEN)
            Global.level_objective_reached.emit()
