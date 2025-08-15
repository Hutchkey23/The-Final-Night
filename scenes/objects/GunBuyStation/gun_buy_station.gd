extends Area2D

signal buy_weapon(weapon: String)
signal buy_ammo(weapon: String)

const COOLDOWN_TIME := 1.5

@export_enum("pistol", "rifle", "shotgun", "sniper_rifle", "rocket_launcher") var weapon: String
var weapon_frames := {
	"sniper_rifle": 0,
	"pistol": 1,
	"revolver": 2,
	"shotgun": 3,
	"rifle": 7,
	"rocket_launcher": 8,
}
@export var weapon_cost := 1500
@export var ammo_cost := 1000

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var gun_sprite: Sprite2D = $GunSprite
@onready var label: Label = $Label

var cooldown = false
var weapon_display_name := ""
var player_in_range = false
var player_reference: Player

func _ready():
	weapon_display_name = format_weapon_name(weapon)
	gun_sprite.frame = weapon_frames[weapon]
	label.visible = false

func _process(delta: float) -> void:
	if cooldown:
		return
	if player_in_range and Input.is_action_just_pressed("interact") and player_reference:
		if player_reference.has_weapon(weapon):
			if player_reference.reserve_ammo[weapon] == WeaponStats.weapon_stats[weapon]["base_max_ammo"]:
				return
			# If player already has weapon, buy ammo
			if PointsManager.points >= ammo_cost:
				PointsManager.add_points(-ammo_cost)
				emit_signal("buy_ammo", weapon)
				cooldown = true
				cooldown_timer.start(COOLDOWN_TIME)
				update_label()
		else:
			# Buy Gun
			if PointsManager.points >= weapon_cost:
				PointsManager.add_points(-weapon_cost)
				emit_signal("buy_weapon", weapon)
				cooldown = true
				cooldown_timer.start(COOLDOWN_TIME)
				update_label()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_reference = body
		player_in_range = true
		update_label()
		label.visible = true
		highlight(true)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_reference = null
		player_in_range = false
		label.visible = false
		highlight(false)
		
func update_label():
	if player_reference and player_reference.has_weapon(weapon):
		label.text = "Buy ammo - " + str(ammo_cost) + " Points"
	else:
		label.text = "Buy " + weapon_display_name + " - " + str(weapon_cost) + " Points"
		
func highlight(state: bool):
	if state:
		gun_sprite.modulate = Color(1.2, 1.2, 1.2)
	else:
		gun_sprite.modulate = Color(1, 1, 1)

func format_weapon_name(name: String) -> String:
	var with_spaces = name.replace("_", " ")
	return with_spaces.capitalize()

func _on_cooldown_timer_timeout() -> void:
	cooldown = false
