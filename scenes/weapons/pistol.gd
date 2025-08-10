extends Node2D

const BULLET_OFFSET = 1.2
const SMALL_BULLET = preload("res://scenes/weapons/small_bullet.tscn")


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_spawn: Node2D = $BulletSpawn
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var reload_timer: Timer = $ReloadTimer

@export var fire_rate := 0.5
@export var max_ammo := 12
@export var reload_length := 2.5

var can_shoot := true
var current_ammo := 12
var is_reloading := false

func shoot(target_position: Vector2):
	# Ensure weapon can be fired (check fire rate, ammo)
	if not can_shoot or is_reloading:
		return

	can_shoot = false
	animation_player.play("shoot")
	
	# Spawn bullet
	var bullet = SMALL_BULLET.instantiate()
	var bullet_container = get_tree().get_first_node_in_group("bullet_container")
	bullet_container.add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	
	# To find direction, subtract the two position vectors and then normalize
	var dir = (target_position - bullet.global_position).normalized()
	bullet.direction = dir
	# Direction vector can also provide rotation angle
	bullet.rotation = dir.angle()
	
	# Handle ammo
	current_ammo -= 1
	check_ammo()
	
	# Start fire rate timer that prevents bullets from firing repeatedly every frame
	if current_ammo > 0:
		fire_rate_timer.start(fire_rate)


func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true


func check_ammo() -> void:
	if current_ammo <= 0 and not is_reloading:
		is_reloading = true
		can_shoot = false
		reload_timer.start(reload_length)


func _on_reload_timer_timeout() -> void:
	current_ammo = max_ammo
	is_reloading = false
	can_shoot = true
