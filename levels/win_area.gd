extends Area2D

func _ready() -> void:
    body_entered.connect(_on_win_area_body_entered)

func _on_win_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        ResourceManager.try_complete_goal()
