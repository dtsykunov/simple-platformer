extends Camera2D

@export var player: CharacterBody2D
@export var follow_speed: float = 5.0 # lower = slower, smoother
@export var bottom_boundary: CollisionShape2D

@onready var camera_offset_y: float = get_viewport().get_visible_rect().size.y * 0.3

func _ready() -> void:
	print("camera_offset_y: ", camera_offset_y)
	global_position = Vector2(get_viewport().get_visible_rect().size.x / 2, camera_offset_y)

func _process(delta: float) -> void:
	# global_position.y = player.global_position.y # jerky camera
	if player.global_position.y < camera_offset_y:
		return
	if player.global_position.y > (bottom_boundary.global_position.y + camera_offset_y):
		return
	global_position.y = lerp(global_position.y, snapped(player.global_position.y, Global.tile_size), follow_speed * delta) # smooth camera
