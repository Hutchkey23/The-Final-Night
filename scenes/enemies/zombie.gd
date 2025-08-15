extends CharacterBody2D

signal hit
signal died

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var zombie_collision: CollisionShape2D = $Zombie1Collision
@onready var zombie_sprite: Sprite2D = $Zombie1Sprite

@export_enum("normal") var zombie_type: String = "normal"
@export var damage := 1
@export var health := 5
@export var move_speed := 50.0

# Hit flash control
var hit_flash_tween: Tween
var hit_flash_timer: SceneTreeTimer
const HIT_FLASH_LENGTH := 0.10

# Navigation controls
var update_interval := 0.3
var time_since_update := 0.0
var stuck_check_interval := 1.0
var last_position := Vector2.ZERO
var offset := Vector2.ZERO
var stuck_timer := 0.0
var stuck_threshold := 5.0
@onready var collision_disable_timer: Timer = $CollisionDisableTimer
const COLLISION_DISABLE_TIME := 0.50

var death_animations = ["death_1", "death_2"]

var attacking_player = false
var is_dying = false
var target: Player

func _ready() -> void:
	match zombie_type:
		"normal":
			health = ZombieStats.normal_zombie_health
			move_speed = ZombieStats.normal_zombie_speed
	target = get_tree().get_first_node_in_group("player")
	offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	last_position = global_position
	
func _physics_process(delta: float) -> void:
	if is_dying:
		return
	process_animation()
	flip_sprites()
	
	# Update navigation target at intervals
	time_since_update += delta
	if time_since_update >= update_interval:
		time_since_update = 0.0
		if target:
			navigation_agent.target_position = target.global_position + offset
	
	var next_point = navigation_agent.get_next_path_position()
	var dir = (next_point - global_position).normalized()
	velocity = dir * move_speed
	
	if attacking_player:
		target.take_damage(damage)

	# Stuck check
	stuck_timer += delta
	if stuck_timer >= stuck_check_interval:
		stuck_timer = 0.0
		if global_position.distance_to(last_position) < stuck_threshold:
			zombie_collision.disabled = true
			collision_disable_timer.start(COLLISION_DISABLE_TIME)
		last_position = global_position

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
	PointsManager.add_points(PointsManager.points_per_hit)
	if health <= 0:
		PointsManager.add_points(PointsManager.points_per_kill)
		is_dying = true
		death()
	else:
		hit_flash()

func hit_flash() -> void:
	# Cancel any running tween/timer so we restart fresh
	if hit_flash_tween and hit_flash_tween.is_running():
		hit_flash_tween.kill()

	var mat = zombie_sprite.material
	mat.set("shader_parameter/solid_color", Color.WHITE)

	# Create a timer for the hold duration before fading
	hit_flash_timer = get_tree().create_timer(HIT_FLASH_LENGTH)

	await hit_flash_timer.timeout

	# Now fade back to transparent
	hit_flash_tween = get_tree().create_tween()
	hit_flash_tween.tween_property(mat, "shader_parameter/solid_color", Color.TRANSPARENT, HIT_FLASH_LENGTH)


func death() -> void:
	# Remove shader material as it affects death animation (sprite not fading if material is present)
	zombie_sprite.material = null
	
	# Stop moving
	velocity = Vector2.ZERO
	
	# Emit signal
	emit_signal("died")
	
	# Choose random death animation
	var death_animation = death_animations.pick_random()
	animation_player.play(death_animation)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		attacking_player = true


func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		attacking_player = false


func _on_collision_disable_timer_timeout() -> void:
	if is_dying:
		return
	zombie_collision.disabled = false
