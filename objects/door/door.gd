extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_opened: bool = false

func _ready() -> void:
	Global.key_obtained.connect(on_key_obtained)

func on_key_obtained() -> void:
	is_opened = true
	anim.play("open")
	sound.play()

func _on_body_entered(body: Node2D) -> void:
	if is_opened and body.is_in_group("player"):
		Global.game_controller.load_next_world()
