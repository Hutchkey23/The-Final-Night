extends StaticBody2D

signal upgrade_weapon(weapon)

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var enchantment_table_animation_player: AnimationPlayer = $EnchantmentTableAnimationPlayer
@onready var input_prompt: Sprite2D = $InputPrompt
@onready var label: Label = $Label

const COOLDOWN_TIME := 1.5

var cooldown = false
var player_in_range = false
var player_reference: Player

func _ready():
	enchantment_table_animation_player.connect("animation_finished", on_animation_finished)
	input_prompt.visible = false
	label.visible = false

func _process(delta: float) -> void:
	if cooldown:
		return
		
	if Input.is_action_just_pressed("interact") and player_in_range:
		enchantment_table_animation_player.play("enchanting_weapon")
		cooldown = true
		cooldown_timer.start(COOLDOWN_TIME)

func on_animation_finished(animation_name) -> void:
	if animation_name == "enchanting_weapon":
		enchantment_table_animation_player.play("idle")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	toggle_label()
	player_in_range = true
	player_reference = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	toggle_label()
	player_in_range = false
	
func toggle_label() -> void:
	label.visible = !label.visible
	input_prompt.visible = !input_prompt.visible


func _on_cooldown_timer_timeout() -> void:
	cooldown = false
