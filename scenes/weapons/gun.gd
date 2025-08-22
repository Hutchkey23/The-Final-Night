extends Node2D

signal fired
signal reload

const BULLET_OFFSET = 1.2
const GUN_OFFSET = Vector2(6, 0)
const SMALL_BULLET = preload("res://scenes/weapons/small_bullet.tscn")
const LARGE_BULLET = preload("res://scenes/weapons/large_bullet.tscn")

@export var weapon_name := "sniper_rifle"
@export_enum("SMALL_BULLET", "LARGE_BULLET") var bullet_type: String
@export var bullet_health := 1
@export var current_reserve_ammo := 30
@export var damage := 5
@export var fire_rate := 1.5
@export var mag_size := 5
@export var max_ammo := 30
@export var reload_length := 3.2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_spawn: Node2D = $BulletSpawn
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var reload_timer: Timer = $ReloadTimer

var active := false
var can_shoot := true
var current_ammo := 5
var is_reloading := false
var weapon_level := 1
var player_reference: Player

func _ready() -> void:
	current_reserve_ammo = max_ammo
	mag_size = WeaponStats.weapon_stats[weapon_name]["mag_size"]
	visible = false
	position = GUN_OFFSET
	
	reload_timer.wait_time = reload_length
	current_ammo = mag_size
	
	player_reference = get_tree().get_first_node_in_group("player")
	
	# Emit signal to update ammo ui
	emit_signal("fired", weapon_name, current_ammo)

func become_active() -> void:
	active = true
	visible = true

func become_inactive() -> void:
	active = false
	visible = false
	if is_reloading:
		reload_timer.stop()
		is_reloading = false
		can_shoot = true

func shoot(target_position: Vector2):
	if !active:
		return
	# Ensure weapon can be fired (check fire rate, ammo)
	if not can_shoot or is_reloading:
		return
	
	if current_ammo <= 0:
		check_ammo()
		return

	can_shoot = false
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("shoot")
	
	# Spawn bullet
	var bullet
	match bullet_type:
		"SMALL_BULLET":
			bullet = SMALL_BULLET.instantiate()
		"LARGE_BULLET":
			bullet = LARGE_BULLET.instantiate()
	bullet.bullet_health = bullet_health
	var bullet_container = get_tree().get_first_node_in_group("bullet_container")
	bullet_container.add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	
	# Set damage of bullet
	bullet.damage = damage
	
	# To find direction, subtract the two position vectors and then normalize
	var dir = (target_position - bullet.global_position).normalized()
	bullet.direction = dir
	# Direction vector can also provide rotation angle
	bullet.rotation = dir.angle()
	
	# Handle ammo
	current_ammo -= 1
	emit_signal("fired", weapon_name, current_ammo)
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
	reload_gun()

func start_reload() -> void:
	is_reloading = true
	can_shoot = false
	reload_timer.start(reload_length)

func reload_gun() -> void:
	var ammo_needed = mag_size - current_ammo
	var ammo_to_load = min(ammo_needed, current_reserve_ammo)
	
	current_reserve_ammo = max(current_reserve_ammo - ammo_to_load, 0)
	current_ammo += ammo_to_load
	emit_signal("reload", weapon_name, ammo_to_load)
	
	is_reloading = false
	can_shoot = true

func upgrade_weapon() -> void:
	weapon_level += 1
	bullet_health = Upgrades.upgrades[weapon_name][weapon_level]["bullet_health"]
	damage = Upgrades.upgrades[weapon_name][weapon_level]["damage"]
	fire_rate = Upgrades.upgrades[weapon_name][weapon_level]["fire_rate"]
	mag_size = Upgrades.upgrades[weapon_name][weapon_level]["mag_size"]
	max_ammo = Upgrades.upgrades[weapon_name][weapon_level]["max_ammo"]
	reload_length = Upgrades.upgrades[weapon_name][weapon_level]["reload_length"]
	
	current_ammo = mag_size
	current_reserve_ammo = max_ammo
	emit_signal("fired", weapon_name, current_ammo)
