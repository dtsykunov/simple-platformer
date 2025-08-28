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

func _ready() -> void:
	anim.play("idle")

func _physics_process(_delta: float) -> void:
	if Global.game_controller.game_state != Main.GameState.PLAYING:
		return
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir):
			move(dir)

func move(dir):
	if state != State.IDLE:
		return
	anim.rotation = inputs[dir].angle()

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
		# Global.grid_spawner.use_cell_at_position(new_position) # so you can pick up exploded items
		if last_player_pos.y != new_position.y and new_position.y < 3 * Global.tile_size: # 3 for space tiles maybe add a check var
			Global.player_reached_surface.emit()
		ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)
		last_player_pos = new_position
		return

	Global.grid_spawner.use_cell_at_position(ray.target_position + position)
	anim.play("mine")
	ResourceManager.add_resource(ResourceManager.ResourceType.OXYGEN, -1)
