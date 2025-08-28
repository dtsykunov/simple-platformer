extends AnimationPlayer

@export var animation_name: String

func _ready():
	play(str(animation_name))
