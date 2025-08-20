extends StaticBody2D

signal transition_to_interior

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var door_open := false

func _ready() -> void:
	WaveManager.connect("wave_changed", on_wave_started)
	WaveManager.connect("wave_ended", on_wave_ended)

func on_wave_started(_wave) -> void:
	if door_open:
		close_door()

func on_wave_ended(wave_number) -> void:
	animation_player.play("open")
	door_open = true


func close_door() -> void:
	animation_player.play("close")
	door_open = false

func _on_transition_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("transition_to_interior", body)
