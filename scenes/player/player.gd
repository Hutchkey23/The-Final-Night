class_name Player
extends CharacterBody2D

signal ammo_changed(current_mag, reserve)
signal health_changed(health, max_health)
signal weapon_changed(weapon_name)

const INVULNERABILITY_LENGTH := 2.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var invulnerable_timer: Timer = $InvulnerableTimer
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var reticle_container: Node2D = $ReticleContainer
@onready var weapon_slot: Node2D = $WeaponPivot

var can_take_damage := true
var current_weapons = []
var health := 5
var max_health := 5

# Weapons
var reserve_ammo := {
	"pistol": 90,
	"rifle": 90,
	"rocket_launcher": 0,
	"shotgun": 0,
	"sniper_rifle": 30,
}

const MOVE_SPEED := 120.0

func _ready() -> void:
	for weapon in weapon_slot.get_children():
		current_weapons.append(weapon)

	weapon_slot.current_weapon.become_active()
	
	for weapon in get_tree().get_nodes_in_group("weapons"):
		weapon.connect("reload", on_weapon_reload)
		weapon.connect("fired", on_weapon_fired)
	# Debug, hide mouse. This will need to be adjusted in other menus/scripts.
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(_delta: float) -> void:
	process_movement()
	process_shooting()
	process_reloading()
	process_weapon_swap()
	animate_sprites()
	flip_sprites()
	move_and_slide()

func process_movement() -> void:
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
	if health <= 0:
		death()
	enter_invulnerable_state()


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
	

func death() -> void:
	print("GAME OVER!")
