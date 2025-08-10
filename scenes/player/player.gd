extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $PlayerSprite

const MOVE_SPEED := 120.0

func _physics_process(delta: float) -> void:
	process_movement()
	animate_sprites()
	flip_sprites()
	move_and_slide()

func process_movement() -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * MOVE_SPEED

func animate_sprites() -> void:
	if velocity == Vector2.ZERO:
		animation_player.play("idle")
	else:
		animation_player.play("run")

func flip_sprites() -> void:
	if velocity.x < 0:
		player_sprite.flip_h = false
	elif velocity.x > 0:
		player_sprite.flip_h = true
