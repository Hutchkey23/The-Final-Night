extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var zombie_sprite: Sprite2D = $Zombie1Sprite

@export var health := 5
@export var move_speed := 50.0

const HIT_FLASH_LENGTH := 0.10

var death_animations = ["death_1", "death_2"]

var is_dying = false
var target: Player

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta: float) -> void:
	if is_dying:
		return
	process_animation()
	flip_sprites()
	
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * move_speed
	

	move_and_slide()

func process_animation() -> void:
	if is_dying:
		return
	else:
		if velocity == Vector2.ZERO:
			animation_player.play("idle")
		else:
			animation_player.play("run")

func flip_sprites() -> void:
	if velocity.x < 0:
		zombie_sprite.flip_h = false
	elif velocity.x > 0:
		zombie_sprite.flip_h = true

func take_damage(damage) -> void:
	if is_dying:
		return
	health -= damage
	if health <= 0:
		is_dying = true
		death()
	else:
		hit_flash()

func hit_flash() -> void:
	var mat = zombie_sprite.material
	mat.set("shader_parameter/solid_color", Color.WHITE)
	await get_tree().create_timer(HIT_FLASH_LENGTH).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(mat, "shader_parameter/solid_color", Color.TRANSPARENT, HIT_FLASH_LENGTH)


func death() -> void:
	# Remove shader material as it affects death animation (sprite not fading if material is present)
	zombie_sprite.material = null
	
	# Stop moving
	velocity = Vector2.ZERO
	
	# Choose random death animation
	var death_animation = death_animations.pick_random()
	animation_player.play(death_animation)
