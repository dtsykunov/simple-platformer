extends CharacterBody2D

@onready var ray = $RayCast2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@onready var last_player_pos = position

enum State {
	IDLE,
	WALKING,
}
var state: State = State.IDLE

var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
}

# current oxygen / length of the shortest path to the sufrace
# ratio when to start shaking
var shake_ratio: float = 1.3
var shake_time: float = 0.0
var max_shake_strength: float = 1.0

func _ready() -> void:
	anim.play("idle")

func _physics_process(_delta: float) -> void:
	if Global.game_controller.game_state != Main.GameState.PLAYING:
		return
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir):
			move(dir)

func _process(delta: float) -> void:
	_process_shake(delta)

func _process_shake(delta: float) -> void:
	# shake character when he's low on oxygen
	var path: Array = Global.grid_spawner.get_shortest_path_to_surface(global_position)

	if path.is_empty():
		return

	var ratio: float = float(ResourceManager.get_resource(ResourceManager.ResourceType.OXYGEN)) / len(path)

	# decide shake strength
	var strength: float = 0.0
	if ratio <= shake_ratio:
		strength = lerp(max_shake_strength, 0.0, clamp(ratio / shake_ratio, 0.0, 1.0))

	# apply shake
	if strength > 0.0:
		shake_time += delta * 30.0
		var offset_x = sin(shake_time) * strength
		var offset_y = cos(shake_time * 1.2) * strength
		anim.position = Vector2(offset_x, offset_y)
	else:
		anim.position = Vector2.ZERO

func move(dir):
	if state != State.IDLE:
		return
	_rotate_player(dir)

	ray.target_position = inputs[dir] * Global.tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		state = State.WALKING
		var new_position = position + inputs[dir] * Global.tile_size
		var tween = create_tween()
		tween.tween_property(self, "position", new_position, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(func():
			state = State.IDLE
			anim.play("idle")
		)
		anim.play("walk")
		if last_player_pos.y != new_position.y and new_position.y < 3 * Global.tile_size: # 3 for space tiles maybe add a check var
			_restore_rotation()
			Global.player_reached_surface.emit()
		ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)

		last_player_pos = new_position
		return

	Global.grid_spawner.use_cell_at_position(ray.target_position + global_position)
	anim.play("mine")
	ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)

func _rotate_player(dir):
	if inputs[dir].x > 0:
		anim.flip_h = false
	elif inputs[dir].x < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false

	if inputs[dir].y > 0.0:
		anim.rotation_degrees = 90
	elif inputs[dir].y < 0.0:
		anim.rotation_degrees = -90
	else:
		anim.rotation_degrees = 0

func _restore_rotation() -> void:
	anim.flip_h = 0
	anim.rotation_degrees = 0
