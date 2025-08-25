extends GPUParticles2D

@onready var time = Time.get_ticks_msec()
@export var lifetime_msec = 1000

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - time > lifetime_msec:
		queue_free()
