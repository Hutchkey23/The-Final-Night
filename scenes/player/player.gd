class_name Player
extends CharacterBody2D

signal ammo_changed(current_mag, reserve)
signal game_over
signal health_changed(health, max_health)
signal weapon_changed(weapon_name)

const CAMERA_TRANSITION_OFFSET := Vector2(0, -20)
const INVULNERABILITY_LENGTH := 2.0
const SMOOTH_DURATION := 0.2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var game_over_screen: ColorRect = $GameOverScreen
@onready var invulnerable_timer: Timer = $InvulnerableTimer
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var reticle_container: Node2D = $ReticleContainer
@onready var weapon_slot: Node2D = $WeaponPivot

var can_move := true
var can_take_damage := true
var current_weapons = []
var health := 5
var max_health := 5

# Weapons
var weapons = {
	"pistol": preload("res://scenes/weapons/pistol/pistol.tscn"),
	"rifle": preload("res://scenes/weapons/rifle/rifle.tscn"),
	"sniper_rifle": preload("res://scenes/weapons/sniper_rifle/sniper_rifle.tscn")
}

var weapon_reticles = {
	"pistol": preload("res://scenes/weapons/pistol/pistol_reticle.tscn"),
	"rifle": preload("res://scenes/weapons/rifle/rifle_reticle.tscn"),
	"sniper_rifle": preload("res://scenes/weapons/rifle/rifle_reticle.tscn")
}

var reserve_ammo := {
	"pistol": 90,
	"rifle": 90,
	"rocket_launcher": 0,
	"shotgun": 0,
	"sniper_rifle": 30,
}

const MOVE_SPEED := 120.0

func _ready() -> void:
	update_weapons()
	
	for gun_buy_station in get_tree().get_nodes_in_group("gun_buy_stations"):
		gun_buy_station.connect("buy_weapon", on_buy_station_buy_weapon)
		gun_buy_station.connect("buy_ammo", on_buy_station_buy_ammo)
	# Debug, hide mouse. This will need to be adjusted in other menus/scripts.
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(_delta: float) -> void:
	process_movement()
	process_shooting()
	process_reloading()
	process_weapon_swap()
	animate_sprites()
	flip_sprites()
	clean_current_weapons()
	move_and_slide()

func process_movement() -> void:
	if !can_move:
		velocity = Vector2.ZERO
		return
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * MOVE_SPEED

func process_shooting() -> void:
	if Input.is_action_pressed("shoot") and weapon_slot.current_weapon:
		var reticle_location = reticle_container.get_child(0).global_position
		weapon_slot.current_weapon.shoot(reticle_location)

func process_reloading() -> void:
	if Input.is_action_just_pressed("reload"):
		weapon_slot.current_weapon.start_reload()

func process_weapon_swap() -> void:
	if Input.is_action_just_pressed("swap") and current_weapons.size() > 1:
		swap_weapon()

func swap_weapon():
	weapon_slot.current_weapon.become_inactive()
	
	if weapon_slot.current_weapon == current_weapons[0]:
		weapon_slot.current_weapon = current_weapons[1]
	else:
		weapon_slot.current_weapon = current_weapons[0]
	
	weapon_slot.current_weapon.become_active()
	
	var swap_reserve_ammo = reserve_ammo[weapon_slot.current_weapon.weapon_name]
	var swap_current_ammo = weapon_slot.current_weapon.current_ammo
	emit_signal("ammo_changed", swap_current_ammo, swap_reserve_ammo)
	emit_signal("weapon_changed", weapon_slot.current_weapon.weapon_name)

func animate_sprites() -> void:
	if velocity == Vector2.ZERO:
		animation_player.play("idle")
	elif velocity != Vector2.ZERO:
		animation_player.play("run")

func flip_sprites() -> void:
	if velocity.x < 0:
		player_sprite.flip_h = false
	elif velocity.x > 0:
		player_sprite.flip_h = true

func on_weapon_reload(weapon_name: String, amount_used: int) -> void:
	reserve_ammo[weapon_name] = max(reserve_ammo[weapon_name] - amount_used, 0)
	var ammo_in_weapon = weapon_slot.current_weapon.current_ammo
	emit_signal("ammo_changed", ammo_in_weapon, reserve_ammo[weapon_name])

func on_weapon_fired(weapon_name: String, current_ammo: int):
	emit_signal("ammo_changed", current_ammo, reserve_ammo[weapon_name])
	
func take_damage(damage) -> void:
	if !can_take_damage:
		return
	health = max(health - damage, 0)
	emit_signal("health_changed", health, max_health)
	if health > 0:
		enter_invulnerable_state()
	else:
		death()
	


func enter_invulnerable_state():
	can_take_damage = false
	modulate = Color(1, 1, 1, 0.5)
	invulnerable_timer.start(INVULNERABILITY_LENGTH)


func _on_invulnerable_timer_timeout() -> void:
	can_take_damage = true
	modulate = Color(1, 1, 1, 1)

func set_camera_boundaries(left_bound, right_bound, top_bound, bottom_bound) -> void:
	camera_2d.limit_left = left_bound
	camera_2d.limit_right = right_bound
	camera_2d.limit_top = top_bound
	camera_2d.limit_bottom = bottom_bound
	
func toggle_camera_smoothing() -> void:
	camera_2d.position_smoothing_enabled = !camera_2d.position_smoothing_enabled

func offset_camera(direction: String) -> void:
	if direction == "up":
		camera_2d.global_position = global_position + CAMERA_TRANSITION_OFFSET
	elif direction == "down":
		camera_2d.global_position = global_position - CAMERA_TRANSITION_OFFSET

func smooth_camera_to_player() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(camera_2d, "global_position", global_position, SMOOTH_DURATION)

func has_weapon(weapon_name: String) -> bool:
	var current_weapon_names = []
	for weapon in current_weapons:
		current_weapon_names.append(weapon.weapon_name)
	return weapon_name in current_weapon_names

func on_buy_station_buy_weapon(weapon_type: String):
	var old_weapon = weapon_slot.current_weapon
	
	# If player has two weapons, replace current one
	if current_weapons.size() >= 2:
		if is_instance_valid(old_weapon):
			old_weapon.queue_free()
			current_weapons.erase(old_weapon)
			
	# Create new weapon
	var purchased_weapon = weapons[weapon_type].instantiate()
	weapon_slot.add_child(purchased_weapon)
	weapon_slot.current_weapon = purchased_weapon
	current_weapons.append(purchased_weapon)
	
	purchased_weapon.become_active()

	emit_signal("weapon_changed", weapon_type)
	emit_signal("ammo_changed", purchased_weapon.current_ammo, reserve_ammo[weapon_type])
	
	update_weapons()

func on_buy_station_buy_ammo(weapon_type: String):
	reserve_ammo[weapon_type] = WeaponStats.weapon_stats[weapon_type]["base_max_ammo"]
	if weapon_slot.current_weapon.weapon_name == weapon_type:
		emit_signal("ammo_changed", weapon_slot.current_weapon.current_ammo, reserve_ammo[weapon_type])

func update_weapons() -> void:
	current_weapons.clear()
	for weapon in weapon_slot.get_children():
		current_weapons.append(weapon)
	
	weapon_slot.current_weapon.become_active()
	
	for weapon in get_tree().get_nodes_in_group("weapons"):
		weapon.connect("reload", on_weapon_reload)
		weapon.connect("fired", on_weapon_fired)
	
	clean_current_weapons()
	

func clean_current_weapons() -> void:
	var clean_array = []
	for item in current_weapons:
		if is_instance_valid(item):
			clean_array.append(item)
	current_weapons = clean_array

func death() -> void:
	set_process(false)
	set_physics_process(false)
	emit_signal("game_over")
	
	modulate = Color(1, 1, 1, 1)
	player_collision.disabled = true
	
	game_over_sequence()
	
func game_over_sequence() -> void:
	player_sprite.z_index = 99
	game_over_screen.z_index = 98
	game_over_screen.visible = true
	weapon_slot.visible = true
	animation_player.stop()
	await get_tree().create_timer(0.5).timeout
	animation_player.play("death")
