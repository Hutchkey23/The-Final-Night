extends StaticBody2D

signal transition_to_interior

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	WaveManager.connect("wave_ended", on_wave_ended)
	
func on_wave_ended(wave_number) -> void:
	animation_player.play("open")


func close_door() -> void:
	animation_player.play("close")

func _on_transition_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("transition_to_interior", body)
