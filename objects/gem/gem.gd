extends Area2D

signal gem_collected

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gem_collected.emit()
		queue_free()
