extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var weapon_slot: Node2D = $WeaponPivot

const MOVE_SPEED := 120.0

func _physics_process(delta: float) -> void:
	process_movement()
	process_shooting()
	animate_sprites()
	flip_sprites()
	move_and_slide()

func process_movement() -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * MOVE_SPEED

func process_shooting() -> void:
	var mouse_pos = get_global_mouse_position()
	if Input.is_action_pressed("shoot") and weapon_slot.current_weapon:
		weapon_slot.current_weapon.shoot(mouse_pos)

func animate_sprites() -> void:
	if velocity == Vector2.ZERO:
		animation_player.play("idle")
	elif velocity > Vector2.ZERO:
		animation_player.play("run")

func flip_sprites() -> void:
	if velocity.x < 0:
		player_sprite.flip_h = false
	elif velocity.x > 0:
		player_sprite.flip_h = true
