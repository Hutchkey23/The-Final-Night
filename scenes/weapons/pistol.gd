extends Node2D

const BULLET_OFFSET = 1.2
const SMALL_BULLET = preload("res://scenes/weapons/small_bullet.tscn")


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_spawn: Node2D = $BulletSpawn
@onready var fire_rate_timer: Timer = $FireRateTimer

@export var fire_rate := 0.5
@export var max_ammo := 15

var can_shoot := true
var current_ammo := 15

func shoot(target_position: Vector2):
	if can_shoot:
		can_shoot = false
		animation_player.play("shoot")
		var bullet = SMALL_BULLET.instantiate()
		var bullet_container = get_tree().get_first_node_in_group("bullet_container")
		bullet_container.add_child(bullet)
		bullet.global_position = bullet_spawn.global_position
		
		var dir = (target_position - bullet.global_position).normalized()
		bullet.direction = dir
		
		fire_rate_timer.start(fire_rate)


func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true
