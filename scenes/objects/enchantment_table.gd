extends StaticBody2D

signal upgrade_weapon(weapon)

@onready var label: Label = $Label

const COOLDOWN_TIME := 1.5

var cooldown = false
var player_in_range = false
var player_reference: Player

func _ready():
	pass

func _process(delta: float) -> void:
	if cooldown:
		return

func _on_interaction_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_interaction_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
