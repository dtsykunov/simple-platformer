extends Node2D


@export var gem_count: int = 5

var gems_collected: int = 0

func _on_gem_collected() -> void:
	gems_collected += 1
	if gems_collected >= gem_count:
		Global.level_objective_reached.emit()
