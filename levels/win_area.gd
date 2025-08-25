extends Area2D

func _ready() -> void:
    body_entered.connect(_on_win_area_body_entered)

func _on_win_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        var goal = ResourceManager.resources["goal"]
        if ResourceManager.resources["money"] >= goal:
            ResourceManager.add_resource("goal", +1)
            ResourceManager.add_resource("money", -goal)
            ResourceManager.set_resource_value("oxygen", ResourceManager.MAX_OXYGEN)
            Global.level_objective_reached.emit()
