extends Camera2D

@export var player: CharacterBody2D
@export var follow_speed: float = 5.0 # lower = slower, smoother
@export var bottom_boundary: CollisionShape2D

@onready var camera_offset_y: float = get_viewport().get_visible_rect().size.y * 0.3

const max_shake: float = 10.0
const shake_fade: float = 10.0

var _shake_strength: float = 0.0


func _ready() -> void:
	position = Vector2(get_viewport().get_visible_rect().size.x / 2, camera_offset_y)

func trigger_shake() -> void:
	_shake_strength = max_shake

func _process(delta: float) -> void:
	_process_shake(delta)
	_process_move(delta)


func _process_move(_delta: float) -> void:
	if player.position.y < camera_offset_y:
		return
	if player.position.y > (bottom_boundary.position.y - camera_offset_y):
		return
	position.y = player.position.y # jerky camera

func _process_shake(delta: float) -> void:
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
		offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))
