extends StaticBody2D

signal upgrade_weapon(weapon)

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var enchantment_table_animation_player: AnimationPlayer = $EnchantmentTableAnimationPlayer
@onready var input_prompt: Sprite2D = $InputPrompt
@onready var label: Label = $Label

const COOLDOWN_TIME := 1.5

var cooldown = false
var player_in_range = false
var player_current_weapon
var player_reference: Player

func _ready():
	player_reference = get_tree().get_first_node_in_group("player")
	player_current_weapon = player_reference.weapon_slot.current_weapon
	enchantment_table_animation_player.connect("animation_finished", on_animation_finished)
	input_prompt.visible = false
	label.visible = false

func _process(delta: float) -> void:
	if cooldown:
		return
	
	if player_current_weapon != player_reference.weapon_slot.current_weapon:
		player_current_weapon = player_reference.weapon_slot.current_weapon
		update_label()
	
	if Input.is_action_just_pressed("interact") and player_in_range:
		var upgrade_cost = get_upgrade_cost(player_reference.weapon_slot.current_weapon.weapon_name, player_reference.weapon_slot.current_weapon.weapon_level)
		if PointsManager.points < upgrade_cost:
			return
		upgrade(upgrade_cost)

func upgrade(upgrade_cost) -> void:
	PointsManager.add_points(-upgrade_cost)
	enchantment_table_animation_player.play("enchanting_weapon")
	player_reference.weapon_slot.current_weapon.upgrade_weapon()
	update_label()
	cooldown = true
	cooldown_timer.start(COOLDOWN_TIME)

func get_upgrade_cost(weapon_name: String, weapon_level: int) -> int:
	var level_to_check = weapon_level + 1
	var cost = Upgrades.upgrades[weapon_name][level_to_check]["cost"]
	return cost

func on_animation_finished(animation_name) -> void:
	if animation_name == "enchanting_weapon":
		enchantment_table_animation_player.play("idle")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	update_label()
	toggle_label()
	player_in_range = true
	player_reference = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	toggle_label()
	player_in_range = false
	
func toggle_label() -> void:
	label.visible = !label.visible
	input_prompt.visible = !input_prompt.visible

func format_weapon_name(name: String) -> String:
	var with_spaces = name.replace("_", " ")
	return with_spaces.capitalize()

func update_label() -> void:
	var weapon_name = format_weapon_name(player_current_weapon.weapon_name)
	var cost = str(get_upgrade_cost(player_reference.weapon_slot.current_weapon.weapon_name, player_reference.weapon_slot.current_weapon.weapon_level))
	label.text = "Upgrade " + weapon_name + " - " + cost + " Points"

func _on_cooldown_timer_timeout() -> void:
	cooldown = false
