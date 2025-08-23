extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.key_obtained.emit()
		queue_free() # Remove the key from the scene after it's obtained
		print("Key obtained by player.")
